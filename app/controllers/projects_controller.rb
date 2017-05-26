require "securerandom"

class ProjectsController < ApplicationController
  before_action :set_project, only: [:edit, :update, :destroy]
  before_action :set_new_project, only: [:index, :new]
  before_action :set_index_instance_variables, only: :index

  rescue_from ActiveRecord::RecordNotFound, with: :invalid_project

  def index
    return unless params[:search]

    @searched_projects = logged_in_out_project_search

    if exact_url_search?(@searched_projects)
      project = @searched_projects.first
      redirect_to github_project_owner_name_url(project.github_owner, project.github_name), notice: "Here's the project you searched for."
    elsif @searched_projects.blank?
      flash[:warning] = "No results found."
    end
  end

  def create
    create_project = create_project_with_default_attributes

    if create_project.current_user_repository_access?
      if create_project.save_project
        if create_project.owner_user_in_db?
          create_project.project.create_github_hook
          redirect_to projects_url, notice: "Project was successfully submitted."
        else
          redirect_to projects_url, notice: "Project was successfully submitted. Waiting for owner to login."
        end
      else
        render :new
      end
    else
      redirect_to projects_url, alert: "We're sorry. Either the project doesn't exist or you don't have permission to add it."
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully destroyed."
  end

  private

  def create_project_with_default_attributes
    create_project = CreateProject.new(project_params: project_params, current_user: current_user)
    # returns create_project object
    create_project.assign_default_attributes
  end

  def assign_project_when_valid_params
    return unless params[:github_owner] && params[:github_name]

    @project =
      Project.find_by(github_owner: params[:github_owner], github_name: params[:github_name])
  end

  def logged_in_out_project_search
    if current_user
      Project.logged_in_search(params[:search], current_user)
    else
      Project.logged_out_search(params[:search])
    end
  end

  def set_index_instance_variables
    @searched_projects = nil
    @latest_public_analysed_projects = Project.latest_public_analysed(5)
    @existing_projects = []
    @missing_projects = []

    user_repositories = current_user ? current_user.github_repositories : false
    update_index_instance_variables(get_repositories_info(user_repositories)) if user_repositories
  end

  def update_index_instance_variables(repositories_info)
    repositories_info.each do |info|
      info_result =
        get_info_result(info[:github_name], info[:github_owner], info[:github_private], info[:svn_url])
      if info_result.is_a?(ActiveRecord::Base)
        @existing_projects << info_result
      else
        @missing_projects << info_result
      end
    end
  end

  def get_repositories_info(user_repositories)
    user_repositories.map do |repository|
      {
        github_name: repository.name,
        github_owner: repository.owner.login,
        github_private: repository.private,
        svn_url: repository.svn_url
      }
    end
  end

  def get_info_result(github_name, github_owner, github_private, svn_url)
    existing_project = Project.where(github_name: github_name, github_owner: github_owner)

    if existing_project.present?
      existing_project.first
    else
      {
        github_name: github_name,
        github_owner: github_owner,
        github_private: github_private,
        svn_url: svn_url
      }
    end
  end

  def set_new_project
    @project = Project.new
  end

  def exact_url_search?(searched_projects)
    searched_projects &&
      searched_projects.count == 1 &&
      params[:search] == searched_projects.first.github_url
  end

  def invalid_project
    logger.error "Attempt to access invalid projects #{params[:id]}"
    redirect_to projects_url, alert: "Invalid project. RecordNotFound"
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:github_url, :github_owner, :github_name, :github_forks, :github_watchers, :github_size, :github_private, :github_homepage, :github_description, :github_fork, :github_has_wiki, :github_has_issues, :github_open_issues, :github_pushed_at, :github_created_at, :github_collaborators, :has_last_report_analyses)
  end
end
