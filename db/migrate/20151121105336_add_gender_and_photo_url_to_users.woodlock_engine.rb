# This migration comes from woodlock_engine (originally 20150903151014)
class AddGenderAndPhotoUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :photo_url, :string
  end
end
