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

  @hooking_key ~r/^HOOK/
  @hooking_value_matcher ~r/^(?<url>.+?)(?:@(?<user_ids>[0-9,]+))?(?:#(?<query>.+))?$/

  def credential_values, do: Application.fetch_env!(:eloido, :twitter) |> String.split(":")
  def tracking_values, do: Application.fetch_env!(:eloido, :track)
  def following_values, do: Application.fetch_env!(:eloido, :follow)
  def hooking_values, do: Application.fetch_env!(:eloido, :hook) |> Enum.filter(&elem(&1, 0) |> String.match?(@hooking_key))

  def twitter_credential do
    ~w(
      consumer_key
      consumer_secret
      access_token
      access_token_secret
    )a |> Enum.zip(credential_values)
  end

  def filtering_parameter do
    parameter = [{:track, tracking_values},
                 {:follow, following_values}] |> Enum.reject(&(elem(&1, 1) |> is_nil))
    Logger.info("Params for statuses/filter: #{inspect parameter}")
    parameter
  end

  def validate_filtering_parameter!(parameter) do
    has_track_or_follow = Keyword.has_key?(parameter, :track) or Keyword.has_key?(parameter, :follow)
    if !has_track_or_follow, do: raise "At least one of environment variables TRACK or FOLLOW must be set"
    parameter
  end

  def hook_configurations do
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
    ExTwitter.configure(twitter_credential)
    filtering_parameter = filtering_parameter |> validate_filtering_parameter!
    twitter_stream = ExTwitter.stream_filter(filtering_parameter, :infinity)

    for hook <- hook_configurations,
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
