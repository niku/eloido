defmodule Eloido.HTTPHandler do
  @moduledoc """
  Handles http request.
  """

  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end
end
