defmodule Eloido.Twitter.Connection do
  use GenServer
  require Logger

  defmodule Config, do: defstruct debug: false, twitter: nil, hooks: nil

  def start_link do
    config = %Config{
      debug: Application.fetch_env!(:eloido, :debug) === "true",
      twitter: Application.fetch_env!(:eloido, :twitter),
      hooks: Enum.map(Application.fetch_env!(:eloido, :hooks), &Eloido.Hook.parse/1)
    }
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config = %Config{}) do
    Logger.info("init")
    {:ok, stream} = do_start_stream(config)
    {:ok, {config, stream}}
  end

  def handle_info({url, tweet = %ExTwitter.Model.Tweet{}}, state) do
    Task.start(Eloido.Idobata, :post, [url, tweet])
    {:noreply, state}
  end

  defp do_start_stream(%Config{twitter: twitter, hooks: hooks}) do
    Logger.info("start twitter stream")
    me = self
    Task.start_link(fn ->
      param = case {twitter[:streaming_parameter][:follow] || "",
                    twitter[:streaming_parameter][:track] || ""} do
                {"", ""} -> []
                {"", track} -> [track: track]
                {follow, ""} -> [follow: follow]
                {follow, track} -> [track: track, follow: follow]
              end
      ExTwitter.configure(:process, twitter[:oauth_token])
      for tweet <- ExTwitter.stream_filter(param, :infinity),
          is_nil(tweet.retweeted_status),
          hook <- hooks,
          Eloido.Hook.match_tweet?(hook, tweet) do
        send(me, {hook.url, tweet})
      end
    end)
  end
end
