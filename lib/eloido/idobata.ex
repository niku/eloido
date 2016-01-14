defmodule Eloido.Idobata do
  @moduledoc """
  Convenience functions for Idobata.
  """

  require Logger

  @doc """
  Builds a content from a tweet.
  """
  @spec build_content(%ExTwitter.Model.Tweet{}) :: String.t
  def build_content(tweet = %ExTwitter.Model.Tweet{}) do
    created_at = Eloido.Twitter.Tweet.parse_twitter_time(tweet.created_at)
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.DateFormat.format!("%Y-%m-%d %T", :strftime)

    EEx.eval_file("lib/eloido/idobata/tweet.eex", tweet: tweet, created_at: created_at)
  end

  @doc """
  Posts to idobata.io as a Custom Webhook
  """
  def post(%Eloido.Idobata.Hook{endpoint: endpoint} = hook) do
    case HTTPoison.post(endpoint,
                        Eloido.Idobata.Hook.encode_query(hook),
                        [{"Content-Type", "application/x-www-form-urlencoded"}]) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.debug(~s(Notify succeed endpoint: #{endpoint}, source: #{hook.source}))
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug(~s(Notify failure endpoint: #{endpoint}, source: #{hook.source}, reason: #{reason}))
    end
  end
end
