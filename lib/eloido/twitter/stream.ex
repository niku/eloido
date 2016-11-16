defmodule Eloido.Twitter.Stream do
  require Logger

  def produce(oauth_token, streaming_parameter) do
    Logger.info("produce twitter stream")
    param = build_param(streaming_parameter)
    ExTwitter.configure(:process, oauth_token)
    ExTwitter.stream_filter(param, :infinity)
  end

  def build_param(keyword) do
    Enum.filter(keyword, fn
      {_k, v} when v in [nil, ""] -> false
      {k, _v} when k in [:follow, :track] -> true
      {k, _v} ->
        Logger.warn "Unexpected key is given: #{k}"
        false
    end)
  end
end
