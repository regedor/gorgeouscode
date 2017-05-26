class CreateProject
  attr_accessor :project

  def initialize(project_params:, current_user:)
    @project = Project.new(project_params)
    @current_user = current_user
  end

  def assign_default_attributes
    @project.added_by_user = @current_user
    @project.update_owner_and_name_from_url
    self
  end

  # Returns true if current_user Github client has access to this project repository.
  def current_user_repository_access?
    client = Octokit::Client.new(access_token: @current_user.github_token)
    client.repository?("#{@project.github_owner}/#{@project.github_name}")
  end

  # Returns true if the project's github_owner already exists in the db.
  def owner_user_in_db?
    User.find_by(github_nickname: @project.github_owner) ? true : false
  end

  def save_project
    @project.save
  end
end
