module Integrations
  class GithubController < ApplicationController
    def fetch_github_commits
        result = Integrations::FetchCommitsService.new(repo: params[:repo], from_sha: params[:from_sha], to_sha: params[:to_sha]).fetch_commits
            
        unless result[:success]
          return render json: { error: result[:errors] }, status: 500
        end
            
        commits = result[:data].each_with_index.map do |commit, idx|
          message = commit['commit']['message']
          sha = commit['sha']
          {
            id: idx,
            title: message.lines.first.strip,
            content: message.lines[1..].join.strip,
            github_commit_url: commit['html_url'],
            short_sha: "#{sha[0..6]}"
          }
        end
    
        render json: commits
      end
    end
  end