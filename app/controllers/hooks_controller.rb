class HooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def github_event
    payload_body = request.body.read
    json = JSON.parse(payload_body)
    project = get_project_from_db(json)
    owner_user = get_owner_user_from_db(json)

    if assign_owner_user_to_project(project, owner_user) &&
       verify_signature(project, payload_body)
      create_report_job(json, project, owner_user)
      render nothing: true, status: 200
    else
      render nothing: true, status: 500
    end
  end

  private

  def create_report_job(json, project, owner_user)
    CreateReportJob.perform_later(
      project: project,
      commit_hash: commit_hash(json, project, owner_user),
      branch: request_github_branch(json)
    )
  end

  def commit_hash(json, project, owner_user)
    json["after"] || last_commit_hash(owner_user, project.github_name)
  end

  def request_github_branch(json)
    json["repository"]["master_branch"] || "master"
  end

  def owner_user_github_nickname(json)
    # responds with json["repository"]["owner"]["login"] when hook is created
    # and json["repository"]["owner"]["name"] to the push event
    json["repository"]["owner"]["login"] || json["repository"]["owner"]["name"]
  end

  def get_project_from_db(json)
    Project.find_by(
      github_name: json["repository"]["name"],
      github_owner: owner_user_github_nickname(json)
    )
  end

  def get_owner_user_from_db(json)
    User.find_by(github_nickname: owner_user_github_nickname(json))
  end

  def assign_owner_user_to_project(project, owner_user)
    if project && owner_user
      unless project.owner_user
        project.owner_user = owner_user
        project.save
      end
      true
    else
      false
    end
  end

  def last_commit_hash(github_owner, github_name)
    client = Octokit::Client.new(access_token: github_owner.github_token)
    client.commits("#{github_owner.github_nickname}/#{github_name}").first.sha
  end

  def verify_signature(project, payload_body)
    signature =
      "sha1=" +
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new("sha1"),
        project.github_secret_token,
        payload_body
      )
    http_signature = request.env["HTTP_X_HUB_SIGNATURE"]

    if Rack::Utils.secure_compare(signature, http_signature)
      true
    else
      raise "Signatures didn't match!"
    end
  end
end
