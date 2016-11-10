defmodule Eloido.Idobata.Connection do
  def start_link(%{} = config) do
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
                GenEvent.notify(config[:idobata_event_manager], %{message | "data" => decoded_data})
              message ->
                GenEvent.notify(config[:idobata_event_manager], message)
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

  def get_channel_name_from_idobata_seed(%{seed_url: seed_url, api_token: api_token, user_agent: user_agent}) do
    %{body: json} = HTTPoison.get!(seed_url, "X-API-Token": api_token, "User-Agent": user_agent)
    Poison.decode!(json)
    |> get_in(["records", "bot", "channel_name"])
  end

  def connect_to_pusher(%{pusher_key: pusher_key, pusher_protocol_version: pusher_protocol_version}) do
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

  def get_auth_and_channel_data_from_idobata_auth(%{auth_url: auth_url, api_token: api_token, user_agent: user_agent}, socket_id, channel_name) do
    %{body: json} = HTTPoison.post!(auth_url, {:form, socket_id: socket_id, channel_name: channel_name}, "X-API-Token": api_token, "User-Agent": user_agent)
    decoded = Poison.decode!(json)
    {Access.get(decoded, "auth"), Access.get(decoded, "channel_data")}
  end

  def subscribe_pusher!(websocket, channel_name, auth, channel_data) do
    Socket.Web.send!(websocket, {:text, Poison.encode!(%{event: "pusher:subscribe", data: %{channel: channel_name, auth: auth, channel_data: channel_data}})})
    {:text, json} = Socket.Web.recv!(websocket)
    %{"event" => "pusher_internal:subscription_succeeded"} = Poison.decode!(json)
  end
end
