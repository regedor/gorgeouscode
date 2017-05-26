require "test_helper"

class ReportTest < ActiveSupport::TestCase
  should belong_to(:project)
  should belong_to(:rails_best_practices_analysis).dependent(:destroy)
  should belong_to(:model_diagram_analysis).dependent(:destroy)
  should belong_to(:code_coverage_analysis).dependent(:destroy)

  should validate_presence_of(:commit_hash)
  should validate_presence_of(:branch)
  should validate_presence_of(:project)

  test "should destroy associated model diagram analyses on destroy" do
    assert_difference "Analyses::ModelDiagramAnalysis.count", -1 do
      reports(:one).destroy
    end
  end

  test "should destroy associated rbp analyses on destroy" do
    assert_difference "Analyses::RailsBestPracticesAnalysis.count", -1 do
      reports(:one).destroy
    end
  end

  test "should have delegated attributes from project" do
    report = Report.new
    report.respond_to?("project_github_name")
    report.respond_to?("project_github_owner")
  end

  test "should have rails_app_present? instance method" do
    report = reports(:one)
    assert report.rails_app_present?
    report = reports(:three)
    refute report.rails_app_present?
  end

  test "should have gc_config_valid? method returning true when it has a valid gc_config" do
    valid_gc_config = { rvm: "2.3.0", before_script: "some command" }

    report = reports(:one)
    report.gc_config = valid_gc_config
    report.save

    assert report.gc_config_valid?
  end

  test "should have gc_config_valid? method returning false when it has a invalid gc_config" do
    valid_gc_config = { rvm: "2.3.0", before_script: "some command" }
    invalid_gc_config_1 = { rvm: "2.3.0" }
    invalid_gc_config_2 = { before_script: "some command" }
    invalid_gc_config_3 = {}

    report = reports(:three)

    report.gc_config = valid_gc_config
    report.save
    assert report.gc_config_valid?

    report.gc_config = invalid_gc_config_1
    report.save
    refute report.gc_config_valid?

    report.gc_config = invalid_gc_config_2
    report.save
    refute report.gc_config_valid?

    report.gc_config = invalid_gc_config_3
    report.save
    refute report.gc_config_valid?
  end

  test "should have gc_config_to_yml method that loads gc_config field and returns YAML" do
    valid_gc_config = { rvm: "2.3.0", before_script: "some command" }
    report = reports(:three)
    report.gc_config = valid_gc_config
    report.save
    # TODO- assert it returns YAML
  end

  test "should have rbp_description instance method returning the description or false" do
    report_three = reports(:three)
    refute report_three.rbp_description
  end
end
