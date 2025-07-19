
# Changelog Summarizer Backend

  
This is the backend service for the Changelog Summarizer application, a tool that fetches commit data from a GitHub repository and generates AI-powered changelogs based on specified commit ranges. The backend provides RESTful APIs to retrieve commit data and generate summaries, supporting the React-based frontend.


## Table of Contents

- [Features](#features)

- [Technologies](#technologies)

- [Prerequisites](#prerequisites)

- [Installation](#installation)
  

## Features

- Fetch commit data from a GitHub repository using a provided repository URL and commit SHAs (from and to).

- Generate AI-powered changelogs using OpenAI for summarizing changes between commits.

- Provide RESTful API endpoints for the frontend to retrieve commit data and changelogs.

- Support for error handling and loading states.

  

## Technologies

-  **Ruby**: Core programming language (version 3.2.x or higher recommended).

-  **Rails**: Web framework for building RESTful APIs (version 7.x or higher).

-  **HTTParty**: HTTP client for interacting with the GitHub API.

-  **OpenAI API**: For generating AI-powered changelog summaries.

-  **dotenv**: For managing environment variables.

-  **Bundler**: For managing Ruby gem dependencies.

  

## Prerequisites

-  **Ruby**: Version 3.2.x or higher.

-  **Bundler**: Version 2.x or higher.

-  **OpenAI API Key**: Required for AI changelog generation.

  

## Installation

1.  **Clone the Repository**
	```bash
	git clone https://github.com/yourusername/ChangelogGenerator-backend.git
	cd ChangelogGenerator-backend
	```

2.  **Bundle Install**
	```bash
	bundle  install
	```

3.  **Add OpenAI access token**
	In your .env file (if there isn't one, create one in the root of the directory), add:

	```bash
	OPENAI_API_KEY=<your_token>
	```
4.  **Start rails server**
Run the below command and ensure you are running the server on localhost:3000
	```bash
	rails server -p 3000
	```