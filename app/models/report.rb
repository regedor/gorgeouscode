require "yaml"

class Report < ActiveRecord::Base
  belongs_to :project
  belongs_to :rails_best_practices_analysis, class_name: "Analyses::RailsBestPracticesAnalysis", dependent: :destroy
  belongs_to :model_diagram_analysis, class_name: "Analyses::ModelDiagramAnalysis", dependent: :destroy
  belongs_to :code_coverage_analysis, class_name: "Analyses::CodeCoverageAnalysis", dependent: :destroy

  validates :commit_hash, presence: true
  validates :branch, presence: true
  validates :project, presence: true

  delegate :github_name, to: :project, prefix: true
  delegate :github_owner, to: :project, prefix: true

  # Returns true if rails_app_path attribute is present.
  def rails_app_present?
    rails_app_path? ? true : false
  end

  # Returns true if gc_config attribute is present and has "rvm" and "before_script" keys.
  def gc_config_valid?
    gc_config.present? && gc_config["rvm"].present? && gc_config["before_script"].present?
  end

  # Returns gc_config attribute in YAML
  def gc_config_to_yml
    YAML.load(gc_config)
  end

  def rbp_description
    rails_best_practices_analysis ? rails_best_practices_analysis.nbp_report_to_hash["description"] : false
  end
end
