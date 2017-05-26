namespace :projects do
  desc "Analyse new projects"
  task analyse_new: :environment do
    Project.without_analysis.each do |project|
      start_report = StartReport.new(
        project: project,
        commit_hash: "local_report_commit",
        branch: "master",
        queued_at: Time.zone.now
      )

      start_report.call
    end
  end

  desc "Pulls all jobs from heroku and analyses all projects last commit"
  task analyse_all_projects_last_commit_from_heroku: :environment do
    pull_from_heroku
    analyse_last_from_delayed_job
  end

  def pull_from_heroku
    FileUtils.mkdir_p(File.join("gc_backups", "db")) unless File.exist?(File.join("gc_backups", "db"))
    system "pg_dump gorgeous-code-alpha_development > gc_backups/db/#{Time.current.strftime('%Y%m%d%H%M%S')}_local_db"
    system "dropdb gorgeous-code-alpha_development"
    system "heroku pg:pull DATABASE_URL gorgeous-code-alpha_development --app gorgeouscode-alpha"
  end

  def analyse_last_from_delayed_job
    project_ids = []

    Delayed::Job.all.reverse.each do |job|
      begin
      project_id =
        job.handler.match(/gid:\/\/gc\/Project\/(\d+)/).values_at(1).first.to_i
      rescue Exception
        "No match"
      end

      next if project_id.nil? || project_ids.include?(project_id)

      project_ids << project_id
      job.invoke_job
    end

    Delayed::Job.destroy_all
  end
end
