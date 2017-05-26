namespace :github_accounts do
  desc "Update github accounts from existing projects"
  task update_from_projects: :environment do
    Project.all.each do |project|
      next if project.github_account

      project.github_account =
        GithubAccount.find_by(name: project.github_owner) || GithubAccount.create!(name: project.github_owner)
      project.save
    end
  end
end
