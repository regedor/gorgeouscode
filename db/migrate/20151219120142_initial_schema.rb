class InitialSchema < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :github_url
      t.string :github_owner
      t.string :github_name
      t.integer :github_forks
      t.integer :github_watchers
      t.integer :github_size
      t.boolean :github_private
      t.string :github_homepage
      t.text :github_description
      t.boolean :github_fork
      t.boolean :github_has_wiki
      t.boolean :github_has_issues
      t.integer :github_open_issues
      t.date :github_pushed_at
      t.date :github_created_at
      t.text :github_collaborators
      t.boolean :analysed, default: false
      t.date :analyse_updated_at
      t.date :github_info_updated_at
      t.integer :added_by_user_id
      t.integer :owner_user_id
      t.timestamps null: false
    end

    create_table :rails_best_practices_analyses do |t|
      t.float :score
      t.text :nbp_report
      t.timestamps null: false
    end

    create_table :model_diagram_analyses do |t|
      t.text :json_data
      t.timestamps null: false
    end

    create_table :reports do |t|
      t.string :commit_hash
      t.string :branch
      t.string :rails_app_path
      t.text :gc_config
      t.string :ruby_version
      t.date :queued_at
      t.date :started_at
      t.date :finished_setup_at
      t.date :finished_at
      t.belongs_to :project, index: true, foreign_key: true
      t.timestamps null: false
    end

    add_reference :reports, :rails_best_practices_analysis, index: true, foreign_key: true
    add_reference :reports, :model_diagram_analysis, index: true, foreign_key: true

    add_column :users, :github_token, :string
  end
end
