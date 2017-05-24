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
    [filters: [&Eloido.reject_retweet/1,
               &Eloido.extract_text_from_tweet/1]]
  end

  def reject_retweet(%{retweeted_status: retweeted_status}) when not is_nil(retweeted_status), do: {:halt, nil}
  def reject_retweet(tweet), do: {:cont, tweet}

  def extract_text_from_tweet(tweet) do
    user_screen_name = tweet.user.screen_name
    tweet_id = tweet.id_str
    template = """
    <img width="16" height="16" src="<%= user_profile_image_url %>">
    &nbsp;
    <b>
    <a href="<%= user_url %>"><%= user_name %></a>
    </b>
    &nbsp;
    <a href="<%= user_url %>">@<%= user_screen_name %></a>
    <br>
    <%= tweet_text %>
    <br>
    <a href="<%= tweet_url %>"><%= tweet_created_at_as_jst %></a>
    """

    doc = EEx.eval_string(template,
      user_name: tweet.user.name,
      user_screen_name: user_screen_name,
      user_profile_image_url: tweet.user.profile_image_url_https,
      tweet_text: tweet.text,
      user_url: "https://twitter.com/" <> user_screen_name,
      tweet_url: "https://twitter.com/#{user_screen_name}/status/#{tweet_id}",
      tweet_created_at_as_jst: datetime_as_jst(tweet.created_at))
    {:cont, doc}
  end

  def datetime_as_jst(twitter_datetime) do
    parsed_date = Timex.Parse.DateTime.Parser.parse!(twitter_datetime, "{WDshort} {Mshort} {D} {ISOtime} {Z} {YYYY}")
    parsed_date
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.Format.DateTime.Formatter.format!("%Y-%m-%d %T", :strftime)
  end

  def build_argument_for_httpc_request(topic, data) do
    method = :post
    url =
      System.get_env("IDOBATA_WEBHOOK")
      |> String.to_charlist
    headers = []
    content_type = 'application/x-www-form-urlencoded'
    body = URI.encode_query(source: data, format: :html)
    request = {url, headers, content_type, body}
    http_options = []
    options = []
    [method, request, http_options, options]
  end
end
