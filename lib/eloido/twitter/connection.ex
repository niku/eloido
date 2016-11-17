defmodule Eloido.Twitter.Connection do
  use GenServer
  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    Logger.info("init")
    {:ok, stream} = do_start_stream(config)
    {:ok, {config, stream}}
  end

  defp do_start_stream(%{oauth_token: oauth_token, streaming_parameter: streaming_parameter, hooks: hooks}) do
    hooks = Enum.map(hooks, &Eloido.Twitter.Hook.parse/1)
    Task.start_link(fn ->
      for tweet <- Eloido.Twitter.Stream.produce(oauth_token, streaming_parameter),
          is_nil(tweet.retweeted_status),
          hook <- hooks,
          Eloido.Twitter.Hook.match_tweet?(hook, tweet) do
        Task.start(Eloido.Twitter.Tweet, :post, [hook.url, tweet])
      end
    end)
  end
end
