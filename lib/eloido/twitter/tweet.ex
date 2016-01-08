defmodule Eloido.Twitter.Tweet do
  @moduledoc """
  Convenience functions for a tweet.
  """

  @doc """
  Checks a tweet is retweet.
  """
  @spec retweet?(%ExTwitter.Model.Tweet{}) :: boolean()
  def retweet?(%ExTwitter.Model.Tweet{retweeted_status: nil}), do: false
  def retweet?(%ExTwitter.Model.Tweet{}), do: true
end
