defmodule Eloido.Twitter.Hook do
  @moduledoc """
  A Hook for matching tweets
  """

  @hooking_value_matcher ~r/^(?<url>.+?)(?:@(?<user_ids>[0-9,]+))?(?:#(?<query>.+))?$/
  @empty_user_ids []
  @empty_query ~r//i

  defstruct source: "", url: "", user_ids: [], query: ~r//i
  @type t :: %__MODULE__{source: String.t, url: String.t, user_ids: [String.t], query: Regex.t}

  @doc """
  Parses string to struct.

  ## Examples

  iex> Eloido.Twitter.Hook.parse({"HOOK_FOO", "http://example.com/foo"})
  %Eloido.Twitter.Hook{query: ~r//i, source: "HOOK_FOO", url: "http://example.com/foo", user_ids: []}

  iex> Eloido.Twitter.Hook.parse({"HOOK_FOO", "http://example.com/foo@123,456#bar"})
  %Eloido.Twitter.Hook{query: ~r/bar/i, source: "HOOK_FOO", url: "http://example.com/foo", user_ids: ["123", "456"]}

  """
  @spec parse({String.t, String.t}) :: t
  def parse({hook_name, string}) do
    %{"url" => url, "user_ids" => user_ids, "query" => query} = Regex.named_captures(@hooking_value_matcher, string)
    splited_user_ids = String.split(user_ids, ",", trim: true)
    compiled_query = Regex.compile!(query, "i")
    %Eloido.Twitter.Hook{source: hook_name, url: url, user_ids: splited_user_ids, query: compiled_query}
  end

  @doc """
  Returns wheather a hook matches with a tweet.

  ## Examples

  iex> Eloido.Twitter.Hook.match_tweet?(%Eloido.Twitter.Hook{query: ~r/bar/i}, %ExTwitter.Model.Tweet{text: "FOOBARBAZ"})
  true

  """
  @spec match_tweet?(t, %ExTwitter.Model.Tweet{}) :: boolean()
  def match_tweet?(%Eloido.Twitter.Hook{user_ids: u, query: q}, _tweet) when u === @empty_user_ids and q === @empty_query do
    # Always match if both values are empty
    true
  end
  def match_tweet?(%Eloido.Twitter.Hook{user_ids: u, query: q}, %ExTwitter.Model.Tweet{user: user}) when q === @empty_query, do: conteins_user_id?(u, user)
  def match_tweet?(%Eloido.Twitter.Hook{user_ids: u, query: q}, %ExTwitter.Model.Tweet{text: text}) when u === @empty_user_ids, do: match_query?(q, text)
  def match_tweet?(%Eloido.Twitter.Hook{user_ids: u, query: q}, %ExTwitter.Model.Tweet{user: user, text: text})  do
    conteins_user_id?(u, user) or match_query?(q, text)
  end

  defp conteins_user_id?(user_ids, user), do: Enum.member?(user_ids, user.id_str)
  defp match_query?(query, text), do: Regex.match?(query, text)
end
