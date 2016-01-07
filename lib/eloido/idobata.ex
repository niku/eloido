defmodule Eloido.Idobata do
  @moduledoc """
  Convenience functions for Idobata.
  """

  @doc """
  Builds a content from a tweet.
  """
  @spec build_content(%ExTwitter.Model.Tweet{}) :: String.t
  def build_content(tweet = %ExTwitter.Model.Tweet{}) do
    created_at = Eloido.Twitter.parse_twitter_time(tweet.created_at)
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.DateFormat.format!("%Y-%m-%d %T", :strftime)

    EEx.eval_file("lib/eloido/idobata/tweet.eex", tweet: tweet, created_at: created_at)
  end
end
