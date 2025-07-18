require 'rails_helper'

RSpec.describe Api::ChangelogsController, type: :controller do
  describe "POST #generate_changelog" do
    let(:openai_response) do
      file_path = Rails.root.join("spec", "fixtures", "files", "sample_changelog.json")
      JSON.parse(File.read(file_path))
    end

    let(:commit_data) do
      file_path = Rails.root.join("spec", "fixtures", "files", "fetch_commits_data.json")
      JSON.parse(File.read(file_path))
    end

    let(:mock_fetch_commits_service) { instance_double(Integrations::FetchCommitsService) }
    let(:mock_generate_changelog_service) { instance_double(Integrations::GenerateChangelogService) }

    before do
      allow(Integrations::FetchCommitsService).to receive(:new).and_return(mock_fetch_commits_service)
      allow(Integrations::GenerateChangelogService).to receive(:new).and_return(mock_generate_changelog_service)
    end

    context "when all services succeed" do
      before do
        allow(mock_fetch_commits_service).to receive(:fetch_commits).and_return({ success: true, data: commit_data })
        allow(mock_generate_changelog_service).to receive(:call).and_return({ success: true, data: openai_response })
      end

      it "returns a successful response and changelog markdown" do
        post :generate_changelog, params: {
          repo: "https://github.com/facebook/react",
          from_sha: "test_from_sha",
          to_sha: "test_to_sha"
        }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include("markdown")
      end
    end

    context "when required parameters are missing" do
      it "returns a 400 with an error message" do
        post :generate_changelog, params: { from_sha: "", to_sha: "" }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
      end
    end

    context "when fetch commits service fails" do
      before do
        allow(mock_fetch_commits_service).to receive(:fetch_commits)
          .and_return({ success: false, errors: "Could not fetch commits" })
      end

      it "returns a 422 with an error" do
        post :generate_changelog, params: {
          repo: "https://github.com/facebook/react",
          from_sha: "from123",
          to_sha: "to456"
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Could not fetch commits")
      end
    end

    context "when generate changelog service fails" do
      before do
        allow(mock_fetch_commits_service).to receive(:fetch_commits).and_return({ success: true, data: commit_data })
        allow(mock_generate_changelog_service).to receive(:call)
          .and_return({ success: false, errors: "AI failed" })
      end

      it "returns a 500 with an error" do
        post :generate_changelog, params: {
          repo: "https://github.com/facebook/react",
          from_sha: "from123",
          to_sha: "to456"
        }

        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("AI failed")
      end
    end
  end
end
