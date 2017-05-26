class ReportsController < ApplicationController
  include ProjectAccessBlocker

  before_action :set_last_report_variables, only: :show_last_report

  def show_last_report
    if @project
      if block_project_access?(@project, current_user)
        redirect_to projects_url, alert: "You don't have access to this project."
      end
      @number_of_percents = 30
    else
      redirect_to projects_url, alert: "Invalid project."
    end
  end

  private

  def set_last_report_variables
    return unless params[:github_owner] && params[:github_name]
    @project =
      Project.where(github_owner: params[:github_owner], github_name: params[:github_name]).first
    @last_report = @project.reports.last || nil
  end
end
