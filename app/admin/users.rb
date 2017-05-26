ActiveAdmin.register User do
  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :confirmed_at

  form do |f|
    f.inputs "User info" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :confirmed_at
      f.actions
    end
  end

  index do
    selectable_column
    id_column
    column :photo do |user|
      image_tag user.photo_url, size: "50x50"
    end
    column :first_name
    column :last_name
    column :email
    actions
  end
end
