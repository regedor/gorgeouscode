# This migration comes from woodlock_engine (originally 20150914082027)
class AddFacebookPhotoUrlAndGooglePhotoUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_photo_url, :string
    add_column :users, :google_photo_url, :string
  end
end
