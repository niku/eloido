defmodule Eloido.Hook do
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

  iex> Eloido.Hook.parse({"HOOK_FOO", "http://example.com/foo"})
  %Eloido.Hook{query: ~r//i, source: "HOOK_FOO", url: "http://example.com/foo", user_ids: []}

  iex> Eloido.Hook.parse({"HOOK_FOO", "http://example.com/foo@123,456#bar"})
  %Eloido.Hook{query: ~r/bar/i, source: "HOOK_FOO", url: "http://example.com/foo", user_ids: ["123", "456"]}

  """
  @spec parse({String.t, String.t}) :: t
  def parse({hook_name, string}) do
    %{"url" => url, "user_ids" => user_ids, "query" => query} = Regex.named_captures(@hooking_value_matcher, string)
    splited_user_ids = String.split(user_ids, ",", trim: true)
    compiled_query = Regex.compile!(query, "i")
    %Eloido.Hook{source: hook_name, url: url, user_ids: splited_user_ids, query: compiled_query}
  end

  @doc """
  Returns wheather a hook matches with a tweet.

  ## Examples

  iex> Eloido.Hook.match_tweet?(%Eloido.Hook{query: ~r/bar/i}, %ExTwitter.Model.Tweet{text: "FOOBARBAZ"})
  true

  """
  @spec match_tweet?(t, %ExTwitter.Model.Tweet{}) :: boolean()
  # FIXME: Sort matching condition
  def match_tweet?(%Eloido.Hook{user_ids: @empty_user_ids, query: @empty_query}, _tweet), do: true # All match if default
  def match_tweet?(%Eloido.Hook{user_ids: user_ids, query: @empty_query}, %ExTwitter.Model.Tweet{user: user}), do: conteins_user_id?(user_ids, user)
  def match_tweet?(%Eloido.Hook{user_ids: @empty_user_ids, query: query}, %ExTwitter.Model.Tweet{text: text}), do: match_query?(query, text)
  def match_tweet?(%Eloido.Hook{user_ids: user_ids, query: query}, %ExTwitter.Model.Tweet{user: user, text: text}) do
    conteins_user_id?(user_ids, user) or match_query?(query, text)
  end

  defp conteins_user_id?(user_ids, user), do: Enum.member?(user_ids, user.id_str)
  defp match_query?(query, text), do: Regex.match?(query, text)
end
