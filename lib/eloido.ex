defmodule Eloido do
  @moduledoc """
  Documentation for Eloido.
  """

  require Logger

  def bot_name, do: "Eloido"

  def adapter do
    %{
      module: Hobot.Plugin.Adapter.TwitterStreaming,
      args: [
        %{
          consumer_key: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :consumer_key),
          consumer_secret: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :consumer_secret),
          access_token: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :access_token),
          access_token_secret: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :access_token_secret),
        },
        %{
          track: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :track),
          follow: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :follow)
        }
      ],
      middleware: %{
        before_publish: [fn {:broadcast, "on_message", ref, tweet} ->
                          Logger.debug(inspect tweet)
                          if tweet.retweeted_status do
                            # Ignore a retweet.
                            # See the `retweeted_status` column in the API reference: https://dev.twitter.com/overview/api/tweets
                            # "Retweets can be distinguished from typical Tweets by the existence of a retweeted_status attribute."
                            Logger.info("Ignore a retweet. tweet id: #{tweet.id}")
                            {:halt, :ignore_a_retweet}
                          else
                            # TODO: update here
                            decorated_tweet = build_html_from_tweet(tweet)
                            Logger.debug("Post a tweet to idobata.io: #{decorated_tweet}")
                            {:ok, {:broadcast, "on_message", ref, decorated_tweet}}
                          end
                        end]
      }
    }
  end

  def handlers do
    [
      %{
        module: Hobot.Plugin.Handler.Idobata.Webhook,
        args: [
          %{
            "on_message" => %{ url: Application.get_env(:hobot_plugin_handler_idobata_webhook, :url) }
          }
        ],
      }
    ]
  end

  defp build_html_from_tweet(tweet) do
    user_screen_name = tweet.user.screen_name
    tweet_id = tweet.id_str
    template = """
    <img width="16" height="16" src="<%= user_profile_image_url %>">&nbsp;<b><a href="<%= user_url %>"><%= user_name %></a></b>&nbsp;<a href="<%= user_url %>">@<%= user_screen_name %></a><br><%= tweet_text %><br><a href="<%= tweet_url %>"><%= tweet_created_at_as_jst %></a>
    """

    EEx.eval_string(template,
      user_name: tweet.user.name,
      user_screen_name: user_screen_name,
      user_profile_image_url: tweet.user.profile_image_url_https,
      tweet_text: tweet.text,
      user_url: "https://twitter.com/#{user_screen_name}",
      tweet_url: "https://twitter.com/#{user_screen_name}/status/#{tweet_id}",
      tweet_created_at_as_jst: datetime_as_jst(tweet.created_at))
  end

  def datetime_as_jst(twitter_datetime) do
    Timex.Parse.DateTime.Parser.parse!(twitter_datetime, "{WDshort} {Mshort} {D} {ISOtime} {Z} {YYYY}")
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.Format.DateTime.Formatter.format!("%Y-%m-%d %T", :strftime)
  end
end
