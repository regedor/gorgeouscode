require "yaml"
require "fileutils"

class StartReport
  def initialize(project:, commit_hash:, branch:, queued_at: Time.zone.now)
    @report = Report.new(
      project: project,
      commit_hash: commit_hash,
      branch: branch,
      queued_at: queued_at
    )
    @project = project
  end

  # Creates new VMConnection, prepares repository and gemset configuration
  # and queues analysers with ActiveJob.
  def call
    @project.has_last_report_analyses = false
    @project.save

    # clone repository
    @report.started_at = Time.zone.now
    connection = VMConnection.new(@report)
    connection.prepare_repository
    @report.rails_app_path = get_rails_path(connection)
    @report.save

    # setup rails app
    if @report.rails_app_present?
      @report.gc_config = connection.get_gc_config([".gc.yml"])
      @report.save

      if copy_project_override_folder(@report, connection) ||
         @report.gc_config_valid?

        @report.ruby_version = connection.search_ruby_version
        @report.save

        # setup do rvm
        # new connection to update @report
        connection = VMConnection.new(@report)
        # got problems with rake tasks folder
        connection.delete_rake_tasks_folder
        connection.prepare_gemset

        # Disable Spring
        connection.disable_spring_in_rails_app

        # database and app .yml.example to .yml, etc
        Rails.logger.debug "\n\n ----- Executing .gc.yml before script... ----- \n\n"
        connection.execute_in_rails_app(@report.gc_config_to_yml["before_script"])
        Rails.logger.debug "\n\n ----- Finished executing .gc.yml before script! ----- \n\n"
        @report.finished_setup_at = Time.zone.now
        @report.save

        # queue analyses jobs, delete gemset and repository
        PerformAnalysesJob.perform_later(@report)
      else
        @project.remove_github_hook
        raise "The current gc_config is invalid and there's no backup file or report project override folder."
      end
    else
      @project.remove_github_hook
      raise "Couldn't find a Rails application."
    end
  end

  private

  def copy_project_override_folder(report, connection)
    path = overrides_path(report)
    if File.exist?(path)
      FileUtils.cp_r(File.join(path, "."), connection.rails_fullpath, remove_destination: true)
      report.gc_config = connection.get_gc_config([".gc.yml"])
      report.save
      true
    else
      false
    end
  end

  def overrides_path(report)
    File.join(
      Rails.application.secrets.overrides_path,
      report.project_github_owner,
      report.project_github_name
    )
  end

  def get_rails_path(connection)
    connection.execute_in_repository(["ls Gemfile"]) ? "/" : nil
  end
end
