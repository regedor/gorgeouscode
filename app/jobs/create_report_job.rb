class CreateReportJob < ActiveJob::Base
  queue_as :default

  def perform(project:, commit_hash:, branch:)
    start_report = StartReport.new(
      project: project,
      commit_hash: commit_hash,
      branch: branch,
      queued_at: Time.zone.now
    )
    start_report.call
  end
end
