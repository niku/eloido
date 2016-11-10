# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :eloido, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:eloido, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :eloido, [
  debug: System.get_env("DEBUG"),
  twitter: [
    oauth_token: [
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
      access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    ],
    streaming_parameter: [
      follow:  System.get_env("FOLLOW"),
      track:   System.get_env("TRACK")
    ],
    hooks: System.get_env |> Enum.filter(fn {k,_v} -> String.match?(k, ~r/^HOOK_/) end),
  ],
  idobata: [
    api_token: System.get_env("IDOBATA_API_TOKEN"),
    pusher_key: System.get_env("IDOBATA_PUSHER_KEY") || "44ffe67af1c7035be764",
    pusher_protocol_version: System.get_env("IDOBATA_PUSHER_PROTOCOL_VERSION") || 7,
    user_agent: System.get_env("IDOBATA_USER_AGENT") || "eloido / v0.1.0",
    seed_url: System.get_env("IDOBATA_SEED_URL") || "https://idobata.io/api/seed",
    auth_url: System.get_env("IDOBATA_AUTH_URL") || "https://idobata.io/pusher/auth"
  ]
]
