# This migration comes from woodlock_engine (originally 20150914082015)
class RemovePhotoUrlFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :photo_url, :string
  end
end
