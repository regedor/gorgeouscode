class AddGithubWebhookIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :github_webhook_id, :integer
  end
end
