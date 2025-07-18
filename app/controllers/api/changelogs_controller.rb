class Api::ChangelogsController < ApplicationController
    def generate_changelog
      # Validate presence of params
      if params[:repo].blank? || params[:from_sha].blank? || params[:to_sha].blank?
        return render_error("Missing required parameters: repo, from_sha, to_sha", :bad_request)
      end
  
      # Fetch commits
      commits_result = Integrations::FetchCommitsService.new(
        repo: params[:repo],
        from_sha: params[:from_sha],
        to_sha: params[:to_sha]
      ).fetch_commits
  
      return render_error(commits_result[:errors], :unprocessable_entity) unless commits_result[:success]
  
      # Generate changelog
      generate_changelog_result = Integrations::GenerateChangelogService.new(
        commits: commits_result[:data]
      ).call
  
      return render_error(generate_changelog_result[:errors], :internal_server_error) unless generate_changelog_result[:success]
  
      render json: { markdown: generate_changelog_result[:data] }, status: :ok
    end
end