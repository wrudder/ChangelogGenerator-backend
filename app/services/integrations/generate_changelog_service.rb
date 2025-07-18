module Integrations
  class GenerateChangelogService
    def initialize(commits:)
      @commits = commits
      @openai_key = Rails.application.credentials.dig(:openai, :api_key)
    end

    attr_reader :commits, :openai_key

    def call
      return error("No OpenAI access token found.") unless openai_key

      client = OpenAI::Client.new(access_token: openai_key)

      parsed_commits = commits.map do |commit|
        message = commit.dig("commit", "message") || ""
        {
          title: message.lines.first&.strip || "",
          content: message.lines[1..]&.join&.strip || ""
        }
      end

      if parsed_commits.empty? || parsed_commits.all? { |c| c[:title].empty? && c[:content].empty? }
        return error("No valid commit messages found.")
      end

      commits_text = parsed_commits.map { |c| "- #{c[:title]}: #{c[:content]}" }.join("\n")

      prompt = <<~PROMPT
        Summarize the following Git commit messages into a well-organized changelog using Markdown.

        Group related changes under clear, bold section headings (e.g., **Bug Fixes**, **Performance Improvements**, **Enhancements**, etc.).

        Use proper Markdown formatting:
        - Start major sections with level 2 headings (##), e.g., ## Compiler or ## Fizz
        - Use bullet points with concise, developer-friendly language
        - Highlight code and identifiers using backticks (e.g., `useEffect`, `eval()`)
        - Use emojis at the beginning of each heading and where appropriate
        - Have a Breaking Changes section at the bottom

        Make the output easy to read in a Markdown renderer like react-markdown. Do not include frontmatter or any extraneous text—only the raw Markdown content.

        Here are the commits:

        #{commits_text}
      PROMPT

      begin
        response = client.chat(
          parameters: {
            model: "gpt-4o",
            messages: [
              { role: "system", content: "You're a helpful changelog generator." },
              { role: "user", content: prompt }
            ],
            temperature: 0.7
          }
        )

        content = response.dig("choices", 0, "message", "content")

        if content.nil? || content.strip.empty?
          return error("OpenAI returned an empty response.")
        end

        markdown = content.gsub("\\n", "\n")
        { success: true, data: markdown }

      rescue OpenAI::Error => e
        error("OpenAI API error: #{e.message}")
      rescue StandardError => e
        error("Unexpected error: #{e.message}")
      end
    end

    private

    def error(message)
      { success: false, errors: message }
    end
  end
end
