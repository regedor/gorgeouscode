require Woodlock::Engine.root.join("app", "models", "user")

class User < ActiveRecord::Base
  has_many :added_projects, class_name: "Project", foreign_key: "added_by_user_id"
  has_many :owned_projects, class_name: "Project", foreign_key: "owner_user_id"

  def photo_url
    github_photo_url || gravatar_url
  end

  def update_github_nickname(auth)
    return unless auth.provider == "github"
    self.github_nickname = auth.info.nickname
  end

  def update_github_token(auth)
    return unless auth.provider == "github"
    self.github_token = auth.credentials.token
  end

  def github_repository_access?(github_name)
    return false unless github_token
    client = Octokit::Client.new(access_token: github_token)
    return true if github_name_exists_in_repositories?(github_name, client.repositories)
    last_response = client.last_response

    while last_response.rels[:next].present?
      last_response_repos = last_response.rels[:next].get.data
      return true if github_name_exists_in_repositories?(github_name, last_response_repos)
    end

    false
  end

  def github_repositories
    return false unless github_token
    client = Octokit::Client.new(access_token: github_token)
    repositories = client.repositories
    last_response = client.last_response

    while last_response.rels[:next].present?
      last_response = last_response.rels[:next].get
      repositories.concat(last_response.data)
    end

    repositories.sort_by(&:name)
  end

  private

  def github_name_exists_in_repositories?(github_name, repositories)
    return true if repositories.any? { |repo| repo.name.eql?(github_name) }
  end

end
