defmodule Eloido do
  require Logger

  @credential_key "TWITTER_AUTH"
  @tracking_key "TRACK"
  @following_key "FOLLOW"
  @hooking_key ~r/^HOOK/
  @hooking_value_matcher ~r/^(?<url>.+?)(?:@(?<user_ids>[0-9,]+))?(?:#(?<query>.+))?$/

  def credential_values, do: System.get_env(@credential_key) |> String.split(":")
  def tracking_values, do: System.get_env(@tracking_key)
  def following_values, do: System.get_env(@following_key)
  def hooking_values, do: System.get_env |> Enum.filter(&elem(&1, 0) |> String.match?(@hooking_key))

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
                 {:follow, following_values}] |> Enum.reject(&(elem(&1, 1) |> nil?))
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

  def start do
    ExTwitter.configure(twitter_credential)
    stream = filtering_parameter |>
    validate_filtering_parameter! |>
    ExTwitter.stream_filter |>
    Stream.reject(&(&1.retweeted)) |>
    Stream.map(fn(x) -> x.text end) |>
    Stream.map(fn(x) -> IO.puts "#{x}\n---------------\n" end)
    Enum.to_list(stream)
  end
end
