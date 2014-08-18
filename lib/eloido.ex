defmodule Eloido do
  @credential_key "TWITTER_AUTH"
  @tracking_key "TRACK"
  @following_key "FOLLOW"

  def credential_values, do: System.get_env(@credential_key) |> String.split(":")
  def tracking_values, do: System.get_env(@tracking_key)
  def following_values, do: System.get_env(@following_key)

  def twitter_credential do
    ~w(
       consumer_key
       consumer_secret
       access_token
       access_token_secret
    )a |> Enum.zip(credential_values)
  end

  def filtering_parameter do
    [{:track, tracking_values},
     {:follow, following_values}] |> Enum.reject(&(elem(&1, 1) |> nil?))
  end

  def start do
    ExTwitter.configure(twitter_credential)
    stream = ExTwitter.stream_filter(filtering_parameter) |>
      Stream.map(fn(x) -> x.text end) |>
      Stream.map(fn(x) -> IO.puts "#{x}\n---------------\n" end)
    Enum.to_list(stream)
  end
end
