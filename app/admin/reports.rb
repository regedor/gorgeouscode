ActiveAdmin.register Report do
  permit_params :commit_hash,
    :branch,
    :rails_app_path,
    :gc_config,
    :ruby_version,
    :queued_at,
    :started_at,
    :finished_setup_at,
    :project_id,
    :rails_best_practices_analysis_id,
    :model_diagram_analysis_id

  index do
    selectable_column
    id_column
    column "Project name" do |report|
      report.project.github_name
    end
    column :rails_best_practices_analysis
    column :model_diagram_analysis
    column :commit_hash
    column :branch
    column :rails_app_path
    column :gc_config
    column :queued_at
    column :started_at
    column :finished_setup_at
    actions
  end
end
