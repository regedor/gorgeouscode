# This migration comes from woodlock_engine (originally 20151123114702)
class AddGithubPhotoUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_photo_url, :string
  end
end
