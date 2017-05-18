defmodule Eloido do
  @moduledoc """
  Documentation for Eloido.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Eloido.hello
      :world

  """
  def hello do
    :world
  end

  def twitter_load_oauth_token do
    [consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
     consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
     access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
     access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")]
  end

  def twitter_load_streaming_param do
    [follow: System.get_env("FOLLOW"),
     track: System.get_env("TRACK")]
  end

  def twitter_topic do
    "twitter_streaming"
  end

  def http_topic_map do
    httpc_request = [:post, {'http://httpbin.org/post', [], [], ""}, [], []]
    %{twitter_topic() => httpc_request}
  end

  def http_plugin_options do
    [filters: [&Eloido.extract_text_from_tweet/1]]
  end

  def extract_text_from_tweet(tweet) do
    tweet.text
  end
end
