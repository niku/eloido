defmodule Eloido.Twitter do

  require Logger

  def start do
    debug = Application.fetch_env!(:eloido, :debug)
    twitter_credential = Application.fetch_env!(:eloido, :twitter)
    track = Application.fetch_env!(:eloido, :track) || ""
    follow = Application.fetch_env!(:eloido, :follow) || ""
    hook = Application.fetch_env!(:eloido, :hook)

    ExTwitter.configure(twitter_credential)
    twitter_stream = Eloido.Twitter.StreamingParameter.build(track, follow) |> ExTwitter.stream_filter
    hooks = Enum.map(hook, &Eloido.Twitter.Hook.parse/1)
    do_post = if debug, do: &IO.puts/2, else: &Eloido.Idobata.post/1

    do_streaming(twitter_stream, hooks, do_post)
  end

  defp do_streaming(twitter_stream, hooks, do_post) do
    for tweet <- twitter_stream,
    hook <- hooks,
    Hook.match_tweet?(hook, tweet),
    !Tweet.retweet?(tweet) do
      content = Eloido.Idobata.build_content(tweet)
      idobata_custom_hook = %Eloido.Idobata.Hook{endpoint: hook.url, source: content, format: :html}
      Task.start(do_post.(idobata_custom_hook))
    end

    do_streaming(twitter_stream, hooks, do_post)
  end
end
