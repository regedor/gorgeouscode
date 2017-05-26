class CreateGithubAccounts < ActiveRecord::Migration
  def change
    create_table :github_accounts do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
