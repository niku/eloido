defmodule Eloido.Twitter do
  defmodule HookMatcher do
    def match?(%{"query" => ""}, _), do: true
    def match?(%{"query" => query, "user_ids" => user_ids },
               %{text: text,
                 user: %{ id_str: id_str }}) do
      match_query(query, text) or contains_user_id(user_ids, id_str)
    end

    defp match_query(query, text), do: Regex.compile!(query, "i") |> Regex.match?(text)
    defp contains_user_id(user_ids, user_id), do: String.contains?(user_ids, user_id)
  end

  require Logger

  @hooking_value_matcher ~r/^(?<url>.+?)(?:@(?<user_ids>[0-9,]+))?(?:#(?<query>.+))?$/

  def build_stream_parameter("", ""), do: build_stream_parameter([])
  def build_stream_parameter(tracking_values, ""), do: build_stream_parameter(track: tracking_values)
  def build_stream_parameter("", following_values), do: build_stream_parameter(follow: following_values)
  def build_stream_parameter(tracking_values, following_values), do: build_stream_parameter(track: tracking_values, follow: following_values)
  defp build_stream_parameter(parameter) do
    Logger.info("Params for statuses/filter: #{inspect parameter}")
    if Enum.empty?(parameter) do
      Logger.warn("At least one of environment variables TRACK or FOLLOW must be setted")
    end
    parameter
  end

  def hook_configurations(hooking_values) do
    configurations = Enum.map(hooking_values,
                              &(Regex.named_captures(@hooking_value_matcher, elem(&1, 1))))
    Logger.info("Hook Configurations: #{inspect configurations}")
    configurations
  end

  def notify(url, message) do
    case HTTPoison.post(url,
                        URI.encode_query(%{source: message, format: "html"}),
                        [{"Content-Type", "application/x-www-form-urlencoded"}]) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.debug(~s(Notify succeed url: #{url}, message: #{message}))
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug(~s(Notify failure url: #{url}, message: #{message}, reason: #{reason}))
    end
  end

  def start do
    twitter_credential = Application.fetch_env!(:eloido, :twitter)
    tracking_values = Application.fetch_env!(:eloido, :track) || ""
    following_values = Application.fetch_env!(:eloido, :follow) || ""
    hooking_values = Application.fetch_env!(:eloido, :hook)

    ExTwitter.configure(twitter_credential)
    stream_parameter = build_stream_parameter(tracking_values, following_values)
    twitter_stream = ExTwitter.stream_filter(stream_parameter, :infinity)

    for hook <- hook_configurations(hooking_values),
    tweet <- twitter_stream,
    HookMatcher.match?(hook, tweet) do
      if retweet?(tweet) do
        Logger.debug("Skip retweet")
      else
        notify(hook["url"], build_message(tweet))
      end
    end
  end

  defp retweet?(tweet) do
    # tweet.retweeted remains always false.
    # tweet.retweet_count remains always 0.
    # So, we use tweet.text for checking retweet.
    Logger.debug(~s(Checking text: #{tweet.text}, retweet?: #{String.starts_with?(tweet.text, "RT @")}))
    String.starts_with?(tweet.text, "RT @")
  end

  defp build_message(tweet) do
    user = tweet.user
    url_user = "https://twitter.com/#{user.screen_name}"
    url_tweet = "https://twitter.com/#{user.screen_name}/status/#{tweet.id_str}"
    EEx.eval_file("lib/notify.eex",
                  user_name: user.name,
                  user_screen_name: user.screen_name,
                  user_profile_image_url_https: user.profile_image_url_https,
                  tweet_created_at: format_time(tweet.created_at),
                  tweet_text: tweet.text,
                  url_user: url_user,
                  url_tweet: url_tweet)
  end

  defp format_time(twitter_time) do
    {:ok, datetime} = Timex.DateFormat.parse(twitter_time, "{UNIX}")
    datetime
    |> Timex.Timezone.convert(Timex.Timezone.get("Asia/Tokyo"))
    |> Timex.DateFormat.format!("%Y-%m-%d %T", :strftime)
  end
end
