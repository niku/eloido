defmodule Eloido.Idobata do
  @moduledoc """
  Convenience functions for Idobata.
  """

  defmodule Config do
    @keys ~w(
      api_token
      pusher_key
      pusher_protocol_version
      user_agent
      seed_url
      auth_url
    )a

    @enforce_keys @keys
    defstruct @keys
  end

  use Timex
  require Logger

  def start_link(idobata_event_manager) do
    idobata_config = Application.fetch_env!(:eloido, :idobata)
    config = %Eloido.Idobata.Config{
      api_token: idobata_config[:api_token],
      pusher_key: idobata_config[:pusher_key],
      pusher_protocol_version: idobata_config[:pusher_protocol_version],
      user_agent: idobata_config[:user_agent],
      seed_url: idobata_config[:seed_url],
      auth_url: idobata_config[:auth_url]
    }
    channel_name = get_channel_name_from_idobata_seed(config)

    websocket = connect_to_pusher(config)
    socket_id = extract_socket_id_from_pusher_socket(websocket)

    {auth, channel_data} = get_auth_and_channel_data_from_idobata_auth(config, socket_id, channel_name)
    subscribe_pusher!(websocket, channel_name, auth, channel_data)

    Task.start_link(fn ->
      loop_func = fn f ->
        case Socket.Web.recv!(websocket) do
          {:text, json} ->
            case Poison.decode!(json) do
              %{"event" => "message_created"} ->
                # Do Nothing
                # http://blog.idobata.io/post/115181024997
                # The message sended from idobata.io is just for a backward compatibility.
                nil
              message = %{"data" => data} ->
                # Recived value on the "data" key is just json string. (double encoded)
                # see https://pusher.com/docs/pusher_protocol#double-encoding
                decoded_data = Poison.decode!(data)
                GenEvent.notify(idobata_event_manager, %{message | "data" => decoded_data})
              message ->
                GenEvent.notify(idobata_event_manager, message)
            end
          {:ping, cookie} ->
            IO.inspect "ping received"
            Socket.Web.pong!(websocket, cookie)
        end
        f.(f)
      end

      loop_func.(loop_func)
    end)
  end

  def get_channel_name_from_idobata_seed(%Config{seed_url: seed_url, api_token: api_token, user_agent: user_agent}) do
    %{body: json} = HTTPoison.get!(seed_url, "X-API-Token": api_token, "User-Agent": user_agent)
    Poison.decode!(json)
    |> get_in(["records", "bot", "channel_name"])
  end

  def connect_to_pusher(%Config{pusher_key: pusher_key, pusher_protocol_version: pusher_protocol_version}) do
    path = "/app/#{pusher_key}?protocol=#{pusher_protocol_version}"
    Socket.Web.connect!("ws.pusherapp.com", secure: true, path: path)
  end

  def extract_socket_id_from_pusher_socket(websocket) do
    {:text, json} = Socket.Web.recv!(websocket)
    Poison.decode!(json)
    |> Access.get("data")
    |> Poison.decode!
    |> Access.get("socket_id")
  end

  def get_auth_and_channel_data_from_idobata_auth(%Config{auth_url: auth_url, api_token: api_token, user_agent: user_agent}, socket_id, channel_name) do
    %{body: json} = HTTPoison.post!(auth_url, {:form, socket_id: socket_id, channel_name: channel_name}, "X-API-Token": api_token, "User-Agent": user_agent)
    decoded = Poison.decode!(json)
    {Access.get(decoded, "auth"), Access.get(decoded, "channel_data")}
  end

  def subscribe_pusher!(websocket, channel_name, auth, channel_data) do
    Socket.Web.send!(websocket, {:text, Poison.encode!(%{event: "pusher:subscribe", data: %{channel: channel_name, auth: auth, channel_data: channel_data}})})
    {:text, json} = Socket.Web.recv!(websocket)
    %{"event" => "pusher_internal:subscription_succeeded"} = Poison.decode!(json)
  end

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
