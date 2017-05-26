module ProjectsHelper
  def humanized_description(project)
    rbp_score = project.reports.last.rails_best_practices_analysis.nbp_report_to_hash["rbp_score"].to_i
    watchers_and_forks_count = project.github_watchers + project.github_forks

    if project.github_private
      private_project_message(project)
    elsif rbp_score > 2 &&
          watchers_and_forks_count < rbp_score * 30 &&
          project.github_created_at > 1.year.ago
      recent_and_good_message(project)
    elsif rbp_score > 2 && watchers_and_forks_count > rbp_score * 100
      good_forst_message(project)
    elsif rbp_score < 3 && project.pushed_at < 1.year.ago
      old_project_message(project)
    else
      normal_report_message(project)
    end
  end

  private

  def private_project_message(project)
    "The project #{project.github_name} is private. Description not available yet."
  end

  def recent_and_good_message(project)
    "#{project.github_name.capitalize} has <strong>#{project.github_watchers} watchers</strong> and <strong>#{project.github_forks} forks</strong> on GitHub. These are not big numbers for a project with a <strong>score of #{project.reports.last.rails_best_practices_analysis.score}</strong>, however the GitHub repository was only created #{time_ago_in_words project.github_created_at} ago. The last update happened #{time_ago_in_words (Time.zone.today - (project.updated_at.to_date - project.github_pushed_at).to_i.days)} before this analisys."
  end

  def old_project_message(project)
    "#{project.github_name.capitalize} has <strong>#{project.github_watchers} watchers</strong> and <strong>#{project.github_forks} forks</strong>. The GitHub repository was created #{time_ago_in_words project.github_created_at} ago, but it had no activity for #{time_ago_in_words project.github_pushed_at} ago. This might explain the low score."
  end

  def good_forks_message(project)
    "#{project.github_name.capitalize} has <strong>#{project.github_watchers} watchers</strong> and <strong>#{project.github_forks}</strong> forks on GitHub. This numbers match the hight level quality of the project.github_ The repository was created #{time_ago_in_words project.github_created_at} ago and the last update happened #{time_ago_in_words (Time.zone.today - (project.updated_at.to_date - project.github_pushed_at).to_i.days)} before this analisys."
  end

  def normal_report_message(project)
    "The repository was created #{time_ago_in_words project.github_created_at} ago, it has <strong>#{project.github_watchers} watchers</strong> and <strong>#{project.github_forks} forks</strong> on GitHub. The last updated happened #{time_ago_in_words project.github_pushed_at} ago."
  end
end
