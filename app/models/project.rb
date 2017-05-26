require "fileutils"
require "yaml"
require "shellwords"

class Project < ActiveRecord::Base
  belongs_to :added_by_user, class_name: "User", foreign_key: "added_by_user_id"
  belongs_to :owner_user, class_name: "User", foreign_key: "owner_user_id"
  belongs_to :github_account

  has_many :reports, dependent: :destroy

  before_create :associate_github_account
  before_destroy :remove_github_hook
  after_create :update_github_info

  serialize :github_collaborators

  validates :github_url, uniqueness: true, format: { with: %r{https:\/\/github.com\/.*} }

  scope :public_repositories, -> { where(github_private: false) }
  scope :private_repositories, -> { where(github_private: true) }
  scope :with_analysis, -> { where(has_last_report_analyses: true) }
  scope :without_analysis, -> { where(has_last_report_analyses: false) }

  # Returns all projects matching a given query to the github_url, github_owner or github_name.
  def self.search(query)
    where("github_url like ?", "%#{query}%") ||
      where("github_owner like ?", "%#{query}%") ||
      where("github_name like ?", "%#{query}%")
  end

  # Returns all analysed projects within a search, where the user is a collaborator, ordered by github_name.
  def self.logged_in_search(search_params, current_user)
    with_analysis
      .search(search_params)
      .order("github_name")
      .reject do |project|
        project.github_private &&
          !current_user.github_repository_access?(project.github_name)
      end
  end

  # Returns all public and analysed projects within a search, ordered by github_name.
  def self.logged_out_search(search_params)
    with_analysis
      .search(search_params)
      .public_repositories
      .order("github_name")
  end

  # Returns the latest n public and analysed projects, ordered by created_at.
  def self.latest_public_analysed(n)
    with_analysis
      .public_repositories
      .order("created_at DESC")
      .limit(n)
  end

  # Creates Github webhook for the project
  def create_github_hook
    owner_user = User.find_by(github_nickname: github_owner)
    return false unless owner_user

    client = Octokit::Client.new(access_token: owner_user.github_token)
    self.github_secret_token = SecureRandom.hex(20)
    save

    create_hook_response =
      client.create_hook(
        repository_name,
        "web",
        { url: Rails.application.secrets.app_hooks_url, content_type: "json", secret: github_secret_token },
        { active: true, events: "push" }
      )

    self.github_webhook_id = create_hook_response["id"]
    save
    true
  end

  def remove_github_hook
    owner_user = User.find_by(github_nickname: github_owner)
    return unless owner_user && github_webhook_id.nil?

    client = Octokit::Client.new(access_token: owner_user.github_token)
    client.remove_hook(repository_name, github_webhook_id)
    self.github_webhook_id = nil
    save
  end

  def update_owner_and_name_from_url
    extract_info_from_url
    save
  end

  # Assigns github_name and github_owner attributes from github_url attribute.
  def extract_info_from_url
    splitted_url = github_url.delete(" ").split("/")
    self.github_name  = splitted_url[-1]
    self.github_owner = splitted_url[-2]
  end

  # Creates a new client connection to Github and updates project related github attributes.
  def update_github_info
    update_owner_and_name_from_url

    client = Octokit::Client.new(access_token: added_by_user.github_token)
    github_repository =
      client.repository?(repository_name) ? client.repository(repository_name) : nil
    return unless github_repository

    self.github_forks = github_repository.forks
    self.github_watchers = github_repository.watchers
    self.github_size = github_repository.size
    self.github_private = github_repository.private
    self.github_homepage = github_repository.homepage
    self.github_description = github_repository.description
    self.github_fork = github_repository.fork
    self.github_has_wiki = github_repository.has_wiki
    self.github_has_issues = github_repository.has_issues
    self.github_open_issues = github_repository.open_issues
    self.github_pushed_at = github_repository.pushed_at
    self.github_created_at = github_repository.created_at
    self.github_collaborators =
      client.collaborators(repository_name) if github_private
    save
  end

  def last_percents(n)
    percents = percents_array(n)
    percents.present? ? percents.to_json : false
  end

  private

  def associate_github_account
    existing_github_account = GithubAccount.find_by(name: github_owner)
    self.github_account =
      existing_github_account || GithubAccount.create!(name: github_owner)
  end

  def percents_array(n)
    reports_with_code_coverage_analysis_percent =
      Report.includes(:code_coverage_analysis)
      .where(project_id: id)
      .where.not(code_coverage_analyses: { percent: nil })
      .order(created_at: :desc)
      .limit(n)

    reports_with_code_coverage_analysis_percent.map do |report|
      {
        "info" => {
          "commit_hash": report.commit_hash,
          "created_at": report.created_at.strftime("%d-%b-%y"),
          "percent": report.code_coverage_analysis.percent
        }
      }
    end.compact
  end

  def repository_name
    "#{github_owner}/#{github_name}"
  end
end
