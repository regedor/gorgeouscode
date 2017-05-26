require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  should belong_to(:added_by_user).class_name("User").with_foreign_key("added_by_user_id")
  should belong_to(:owner_user).class_name("User").with_foreign_key("owner_user_id")
  should belong_to(:github_account)
  should have_many(:reports)
  should validate_uniqueness_of(:github_url)

  should allow_value("https://github.com/regedor").for(:github_url)
  should_not allow_value("http://github.com/regedor").for(:github_url)
  should_not allow_value("https://wrong-url.com/regedor").for(:github_url)

  def test_destroys_associated_reports_on_destroy
    Project.any_instance.stubs(:remove_github_hook).returns(true)
    report_count = projects(:apiflat_book).reports.count

    assert_difference "Report.count", -(report_count) do
      projects(:apiflat_book).destroy
    end
  end

  def test_has_update_owner_and_name_from_url_instance_method
    project = Project.new(github_url: "https://github.com/regedor/test-project")

    project.stub :update_github_info, true do
      project.update_owner_and_name_from_url
    end

    assert_equal "regedor", project.github_owner
    assert_equal "test-project", project.github_name
  end

  def test_has_search_class_method_returning_form_github_url_github_owner_or_github_name_queries
    assert_equal Project.count, Project.search(".com").count
    assert_equal 3, Project.search("ptmiguelfernandes").count
    assert_equal 2, Project.search("miguelregedor-privateproject").count
  end

  def test_has_logged_in_search_class_method_returning_analysed_projects_with_user_access
    current_user = users(:miguelfernandes)

    User.any_instance.stubs(:github_repository_access?).returns(true)
    assert_equal 2, Project.logged_in_search("miguelfernandes", current_user).count
    assert_equal 1, Project.logged_in_search("miguelregedor", current_user).count

    Project.any_instance.stubs(:github_collaborator?).returns(false)
    assert_equal 0, Project.logged_in_search("miguelregedor-privateproject1", current_user).count
  end

  def test_has_logged_out_search_class_method_returning_all_public_analysed_projects
    assert_equal 2, Project.logged_out_search("miguelfernandes").count
    assert_equal 1, Project.logged_out_search("apiflat_book").count
    assert_equal 0, Project.logged_out_search("miguelregedor-privateproject1").count
  end

  def test_returns_last_n_code_coverage_analyses_percent_json
    last_percents_number = 3
    assert_equal projects(:apiflat_book).last_percents(last_percents_number), last_apiflat_percent_json(last_percents_number)
  end

  def last_apiflat_percent_json(n)
    project = projects(:apiflat_book)

    reports_with_code_coverage_analysis_percent =
      Report.includes(:code_coverage_analysis)
      .where(project_id: project.id)
      .where.not(code_coverage_analyses: { percent: nil })
      .order(created_at: :desc)
      .limit(n)

    reports_with_code_coverage_analysis_percent.map do |report|
      next unless report.code_coverage_analysis.percent
      {
        "info" => {
          "commit_hash": report.commit_hash,
          "created_at": report.created_at.strftime("%d-%b-%y"),
          "percent": report.code_coverage_analysis.percent
        }
      }
    end.compact.to_json
  end
end
