require 'rails_helper'

RSpec.describe Integrations::GithubController, type: :controller do
  describe "GET #fetch_github_commits" do
    let(:repo) { "my/repo" }
    let(:from_sha) { "abc123" }
    let(:to_sha) { "def456" }
    let(:service_instance) { instance_double(Integrations::FetchCommitsService) }

    before do
      allow(Integrations::FetchCommitsService).to receive(:new)
        .with(repo: repo, from_sha: from_sha, to_sha: to_sha)
        .and_return(service_instance)
    end

    context "when fetch_commits succeeds" do
      let(:commit_data) do
        [
          {
            "sha" => "abcdef1234567890",
            "commit" => { "message" => "Fix bug\nMore details" },
            "html_url" => "https://github.com/my/repo/commit/abcdef1234567890"
          }
        ]
      end

      before do
        allow(service_instance).to receive(:fetch_commits)
          .and_return(success: true, data: commit_data)
      end

      it "renders the formatted commits as JSON" do
        get :fetch_github_commits, params: { repo: repo, from_sha: from_sha, to_sha: to_sha }

        expect(response).to have_http_status(:ok)

        expected_response = [
          {
            id: 0,
            title: "Fix bug",
            content: "More details",
            github_commit_url: "https://github.com/my/repo/commit/abcdef1234567890",
            short_sha: "abcdef1"
          }
        ].as_json

        expect(response.body).to eq(expected_response.to_json)
      end
    end

    context "when fetch_commits fails" do
      before do
        allow(service_instance).to receive(:fetch_commits)
          .and_return(success: false, errors: "Failed to fetch commits")
      end

      it "renders an error JSON with status 500" do
        get :fetch_github_commits, params: { repo: repo, from_sha: from_sha, to_sha: to_sha }

        expect(response).to have_http_status(500)
        expect(JSON.parse(response.body)).to eq({ "error" => "Failed to fetch commits" })
      end
    end
  end
end
