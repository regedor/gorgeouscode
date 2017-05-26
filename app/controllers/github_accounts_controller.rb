class GithubAccountsController < ApplicationController
  include GithubAccountAccessBlocker
  before_action :set_github_account, only: :show

  def show
    if block_github_account_access?(@github_account.name, current_user)
      redirect_to projects_url, alert: "Access denied to Github account. Authorization and login required."
      return
    end

    @projects = @github_account.projects
    num_of_projects = @projects.count
    @average_code_coverage_percent = (get_total_code_coverage_percent / num_of_projects).round(2)
    @average_rbp_score = (get_total_rbp_score / num_of_projects).round(2)
  end

  private

  def get_total_rbp_score(projects)
    projects.map do |project|
      project.reports.last.rails_best_practices_analysis.score
    end.reject { |score| score == 0 }.sum
  end

  def get_total_code_coverage_percent(projects)
    projects.map do |project|
      project.reports.last.code_coverage_analysis.percent || 0
    end.reject { |percent| percent == 0 }.sum
  end

  def invalid_github_account
    logger.error "Attempt to access invalid Github account #{params[:name]}"
    redirect_to projects_url, alert: "Invalid Github account. RecordNotFound"
  end

  def set_github_account
    @github_account = GithubAccount.find_by(name: params[:name])
    unless @github_account
      redirect_to projects_url, alert: "Invalid Github account."
      return
    end
  end

  def github_account_params
    params.require(:github_account).permit(:name)
  end
end
