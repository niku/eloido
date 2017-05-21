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
    %{twitter_topic() => &build_argument_for_httpc_request/2}
  end

  def http_plugin_options do
    [filters: [&Eloido.extract_text_from_tweet/1]]
  end

  def extract_text_from_tweet(tweet) do
    tweet.text
  end

  def build_argument_for_httpc_request(topic, data) do
    method = :post
    url = 'http://httpbin.org/post'
    header = []
    content_type = []
    body = data
    request = {url, headers, content_type, body}
    http_options = []
    options = []
    [method, request, http_options, options]
  end
end
