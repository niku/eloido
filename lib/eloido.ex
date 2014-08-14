defmodule Eloido do
  @credential_key "TWITTER_AUTH"

  def credential_values, do: System.get_env(@credential_key) |> String.split(":")

  def twitter_credential do
    ~w(
       consumer_key
       consumer_secret
       access_token
       access_token_secret
    )a |> Enum.zip(credential_values)
  end

  def start do
    ExTwitter.configure(twitter_credential)
    stream = ExTwitter.stream_filter(track: "apple") |>
      Stream.map(fn(x) -> x.text end) |>
      Stream.map(fn(x) -> IO.puts "#{x}\n---------------\n" end)
    Enum.to_list(stream)
  end
end
