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

  def handle_info({url, tweet = %ExTwitter.Model.Tweet{}}, state) do
    Task.start(Eloido.Twitter.Connection, :post, [url, tweet])
    {:noreply, state}
  end

  def post(endpoint, tweet = %ExTwitter.Model.Tweet{}) do
    body = URI.encode_query(source: Eloido.Twitter.Builder.build_source(tweet), format: :html)
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.debug(~s(Notify succeed endpoint: #{endpoint}, text: #{tweet.text}))
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug(~s(Notify failure endpoint: #{endpoint}, text: #{tweet.text}, reason: #{reason}))
    end
  end

  defp do_start_stream(%{oauth_token: oauth_token, streaming_parameter: streaming_parameter, hooks: hooks}) do
    me = self
    hooks = Enum.map(hooks, &Eloido.Twitter.Hook.parse/1)
    Task.start_link(fn ->
      for tweet <- Eloido.Twitter.Stream.produce(oauth_token, streaming_parameter),
          is_nil(tweet.retweeted_status),
          hook <- hooks,
          Eloido.Twitter.Hook.match_tweet?(hook, tweet) do
        send(me, {hook.url, tweet})
      end
    end)
  end
end
