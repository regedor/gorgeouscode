class AddGithubSecretTokenToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :github_secret_token, :string
  end
end
