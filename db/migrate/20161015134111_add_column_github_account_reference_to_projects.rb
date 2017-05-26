class AddColumnGithubAccountReferenceToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :github_account, index: true, foreign_key: true
  end
end
