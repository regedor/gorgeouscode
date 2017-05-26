require "fileutils"

class StartReportTest < ActiveSupport::TestCase
  test "should complete report with analysers with call method" do
    skip
    FileUtils.rm_rf(VMConnection::VMS_ROOT)
    FileUtils.rm_rf(Rails.application.secrets.project_json)
    Report.destroy_all
    project = projects(:apiflat_book)

    assert_equal 0, project.reports.count
    assert_not_nil project.added_by_user
    assert_not_nil project.owner_user

    StartReport.new(
      project: project,
      commit_hash: "aae0d0b728a05b95fd7c0788e0f8879d2ab9f613",
      branch: "master",
      queued_at: Time.current - 1.minute
    ).call

    assert_equal 1, project.reports.count

    report = project.reports.first
    assert_equal true, report.rails_app_present?
    assert_equal true, report.gc_config_valid?
    assert_not_nil report.finished_setup_at

    assert report.rails_best_practices_analysis, "Report doesn't have any rails best practices analysis."
    assert_not_nil report.rails_best_practices_analysis.score
    assert_not_nil report.rails_best_practices_analysis.nbp_report

    assert report.model_diagram_analysis, "Report doesn't have any model diagram analysis."
    assert_not_nil report.model_diagram_analysis.json_data
  end
end
