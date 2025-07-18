Rails.application.routes.draw do
  namespace :api do
    post 'generate_changelog', to: 'changelogs#generate_changelog'
  end

  namespace :integrations do
    get 'github/fetch_github_commits', to: 'github#fetch_github_commits'
  end
end
