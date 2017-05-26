Woodlock.setup do |config|
  config.site_name = "Gorgeous Code"
  config.site_email = "noreply@regedor.com"
  config.site_url = "https://gorgeouscode-alpha.herokuapp.com"
  config.gravatar_default_url = "https://gorgeouscode-alpha.herokuapp.com/no_user.png"
  config.authentication_services = ["github"]
  config.github_scope = "user:email, repo"
  config.github_callback_url = "https://gorgeouscode-alpha.herokuapp.com/auth/github/callback"
  # config.disable_welcome_email = true
end
