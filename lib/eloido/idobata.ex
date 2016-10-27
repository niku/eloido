defmodule Eloido.Idobata do
  @moduledoc """
  Convenience functions for Idobata.
  """

  use Timex
  require Logger

  def post(endpoint, tweet = %ExTwitter.Model.Tweet{}) do
    body = URI.encode_query(source: build_source(tweet), format: :html)
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.debug(~s(Notify succeed endpoint: #{endpoint}, text: #{tweet.text}))
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug(~s(Notify failure endpoint: #{endpoint}, text: #{tweet.text}, reason: #{reason}))
    end
  end

  def build_source(tweet = %ExTwitter.Model.Tweet{}) do
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

    EEx.eval_string(template,
      user_name: tweet.user.name,
      user_screen_name: user_screen_name,
      user_profile_image_url: tweet.user.profile_image_url_https,
      tweet_text: tweet.text,
      user_url: "https://twitter.com/#" <> user_screen_name,
      tweet_url: "https://twitter.com/#{user_screen_name}/status/#{tweet_id}",
      tweet_created_at_as_jst: datetime_as_jst(tweet.created_at))
  end

  def datetime_as_jst(twitter_datetime) do
    Timex.Parse.DateTime.Parser.parse!(twitter_datetime, "{WDshort} {Mshort} {D} {ISOtime} {Z} {YYYY}")
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.Format.DateTime.Formatter.format!("%Y-%m-%d %T", :strftime)
  end
end
