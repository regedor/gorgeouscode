class ModelOverviewController < ApplicationController
  include ProjectAccessBlocker

  before_action :assign_project_from_params, only: :show_last_report_model_overview

  layout false

  def show_last_report_model_overview
    @model_diagram_json = nil
    project_reports = @project.reports if @project

    if project_reports
      last_model_diagram_analysis =
        project_reports.last.model_diagram_analysis

      if !last_model_diagram_analysis
        redirect_to projects_url, alert: "The project is missing or not analysed yet."
      elsif block_project_access?(@project, current_user)
        redirect_to projects_url, alert: "You don't have access to this project."
      elsif last_model_diagram_analysis.json_data?
        @model_diagram_json = last_model_diagram_analysis.json_data
      end
    else
      redirect_to projects_url, alert: "Invalid project."
    end
  end

  private

  def assign_project_from_params
    @project =
      Project.find_by(
        github_owner: params[:github_owner],
        github_name: params[:github_name]
      )
  end

  def model_overview_params
    params
      .require(:project)
      .permit(
        :github_url,
        :github_owner,
        :github_name,
        :github_private,
        :has_last_report_analyses
      )
  end
end
