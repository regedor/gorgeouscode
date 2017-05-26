ActiveAdmin.register Project do
  permit_params :github_url,
    :github_owner,
    :github_name,
    :github_forks,
    :github_fork,
    :github_watchers,
    :github_size,
    :github_private,
    :github_homepage,
    :github_description,
    :github_has_wiki,
    :github_has_issues,
    :github_open_issues,
    :github_pushed_at,
    :github_created_at,
    :has_last_report_analyses

  index do
    selectable_column
    id_column
    column :github_owner
    column :github_name
    column :github_forks
    column :github_fork
    column :github_watchers
    column :github_private
    column :github_analysed
    column :github_has_issues
    column :github_open_issues
    column :has_last_report_analyses
    actions
  end
end
