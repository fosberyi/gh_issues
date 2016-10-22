defmodule GhIssues.GitHub do

  require Logger

  @github_url Application.get_env(:gh_issues, :github_url)
  @user_agent [{"User-agent", "Elixir ian@codeguy.io"}]

  def fetch(user, project) do
    Logger.info "Fetching issues for #{user}'s project: #{project}"
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({_, %{status_code: status, body: body}}) do
    Logger.error "Error #{status} returned"
    { :error, Poison.Parser.parse!(body) }
  end
end
