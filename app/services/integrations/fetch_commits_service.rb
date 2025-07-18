module Integrations
    class FetchCommitsService
      def initialize(repo: nil, from_sha:, to_sha:)
        @repo = repo
        @from_sha = from_sha
        @to_sha = to_sha
      end

      attr_reader :repo, :from_sha, :to_sha

      def fetch_commits
        return { success: false, errors: 'Please provide from and to commit SHAs' } if from_sha.blank? || to_sha.blank?

        response = HTTParty.get(url, headers: headers)

        unless response&.success?
          return { success: false, errors: response['message'] || "An unknown error occurred" }
        end

        commits = response.parsed_response['commits'] || []

        { success: true, data: commits }
      end

      private

      def url
        "https://api.github.com/repos/#{repo_path}/compare/#{from_sha}...#{to_sha}"
      end

      def repo_path 
        repo[%r{github\.com/([\w.-]+/[\w.-]+)}, 1]
      end

      def headers
        {
          # "Authorization" => "Bearer #{ENV['GITHUB_ACCESS_TOKEN']}", Was going to include private repos but pressed for time
          "User-Agent" => "GreptileApp",
          "Accept" => "application/vnd.github.v3+json"
        }
      end
    end
  end