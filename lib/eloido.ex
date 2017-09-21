defmodule Eloido do
  @moduledoc """
  Documentation for Eloido.
  """

  require Logger

  def bot_name, do: "Eloido"

  def adapter do
    %{
      module: Hobot.Plugin.Adapter.TwitterStreaming,
      args: [
        %{
          consumer_key: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :consumer_key),
          consumer_secret: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :consumer_secret),
          access_token: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :access_token),
          access_token_secret: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :access_token_secret),
        },
        %{
          track: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :track),
          follow: Application.get_env(:hobot_plugin_adapter_twitter_streaming, :follow)
        }
      ],
      middleware: %{
        before_publish: [fn {:broadcast, "on_message", ref, tweet} ->
                          Logger.debug(inspect tweet)
                          # TODO: update here
                          {:ok, {:broadcast, "on_message", ref, tweet.text}}
                        end]
      }
    }
  end

  def handlers do
    [
      %{
        module: Hobot.Plugin.Handler.Idobata.Webhook,
        args: [
          %{
            "on_message" => %{ url: Application.get_env(:hobot_plugin_handler_idobata_webhook, :url) }
          }
        ],
      }
    ]
  end
end
