# This migration comes from woodlock_engine (originally 20151130094115)
class AddGithubNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_nickname, :string
  end
end
