module ProjectAccessBlocker
  extend ActiveSupport::Concern

  def block_project_access?(project, current_user)
    logged_out_private(project, current_user) ||
      logged_in_private_without_access(project, current_user)
  end

  private

  def logged_out_private(project, current_user)
    !current_user && project.github_private
  end

  def logged_in_private_without_access(project, current_user)
    current_user &&
      project.github_private &&
      !current_user.github_repository_access?(project.github_name)
  end
end
