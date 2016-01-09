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

  @doc """
  Parses time representation of Twitter.

  ## Examples

  iex> Eloido.Twitter.Tweet.parse_twitter_time("Wed Aug 27 13:08:45 +0000 2008")
  %Timex.DateTime{calendar: :gregorian, day: 27, hour: 13, minute: 8, month: 8, ms: 0, second: 45,
    timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2008}

  """
  @spec parse_twitter_time(String.t) :: %Timex.DateTime{}
  def parse_twitter_time(twitter_time) do
    Timex.DateFormat.parse!(twitter_time, "{WDshort} {Mshort} {D} {ISOtime} {Z} {YYYY}")
  end

  @doc """
  Builds url of a user which posts a tweet.

  ## Examples

  iex> Eloido.Twitter.Tweet.build_user_url(%ExTwitter.Model.Tweet{user: %ExTwitter.Model.User{screen_name: "foo"}})
  "https://twitter.com/foo"

  """
  @spec build_user_url(%ExTwitter.Model.Tweet{}) :: String.t
  def build_user_url(%ExTwitter.Model.Tweet{user: %ExTwitter.Model.User{screen_name: screen_name}}), do: "https://twitter.com/#{screen_name}"

  @doc """
  Builds url of a tweet.

  ## Examples

  iex> Eloido.Twitter.Tweet.build_tweet_url(%ExTwitter.Model.Tweet{id_str: "12345", user: %ExTwitter.Model.User{screen_name: "foo"}})
  "https://twitter.com/foo/status/12345"

  """
  @spec build_tweet_url(%ExTwitter.Model.Tweet{}) :: String.t
  def build_tweet_url(%ExTwitter.Model.Tweet{id_str: id, user: %ExTwitter.Model.User{screen_name: screen_name}}), do: "https://twitter.com/#{screen_name}/status/#{id}"
end
