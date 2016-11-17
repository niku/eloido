defmodule Eloido.Twitter.HookTest do
  use ExUnit.Case, async: true
  doctest Eloido.Twitter.Hook

  test "parse/1" do
    hook_name = "HOOK_FOO"
    url = "https://example.com/foo"
    user_ids = "@1234,5678"
    query = "#bar"
    assert Eloido.Twitter.Hook.parse({hook_name, url}) == %Eloido.Twitter.Hook{source: hook_name, url: url, query: ~r//i, user_ids: []}
    assert Eloido.Twitter.Hook.parse({hook_name, url <> user_ids}) == %Eloido.Twitter.Hook{source: hook_name, url: url, query: ~r//i, user_ids: ["1234", "5678"]}
    assert Eloido.Twitter.Hook.parse({hook_name, url <> query}) == %Eloido.Twitter.Hook{source: hook_name, url: url, query: ~r/bar/i, user_ids: []}
    assert Eloido.Twitter.Hook.parse({hook_name, url <> user_ids <> query}) == %Eloido.Twitter.Hook{source: hook_name, url: url, query: ~r/bar/i, user_ids: ["1234", "5678"]}
  end

  test "match_tweet?/2 when hook contains tweet's user_id" do
    hook = %Eloido.Twitter.Hook{query: ~r/abc/i, user_ids: ["2339", "1234"]}
    tweet = %ExTwitter.Model.Tweet{text: "abc", user: %ExTwitter.Model.User{id_str: "1234"}}
    assert Eloido.Twitter.Hook.match_tweet?(hook, tweet)
  end

  test "match_tweet?/2 when hook didn't contain tweet's user_id" do
    hook = %Eloido.Twitter.Hook{user_ids: ["2339", "1235"]}
    tweet = %ExTwitter.Model.Tweet{text: "abc", user: %ExTwitter.Model.User{id_str: "1234"}}
    refute Eloido.Twitter.Hook.match_tweet?(hook, tweet)
  end

  test "match_tweet?/2 when hook matches tweet's text" do
    hook = %Eloido.Twitter.Hook{query: ~r/ばー/i}
    tweet = %ExTwitter.Model.Tweet{text: "ふーばーばず"}
    assert Eloido.Twitter.Hook.match_tweet?(hook, tweet)
  end

  test "match_tweet?/2 when hook didn't match tweet's text" do
    hook = %Eloido.Twitter.Hook{query: ~r/ばーー/i}
    tweet = %ExTwitter.Model.Tweet{text: "ふーばーばず"}
    refute Eloido.Twitter.Hook.match_tweet?(hook, tweet)
  end

  test "match_tweet?/2 maching case insensitive" do
    hook = %Eloido.Twitter.Hook{query: ~r/bar/i}
    tweet = %ExTwitter.Model.Tweet{text: "FOOBARBAZ"}
    assert Eloido.Twitter.Hook.match_tweet?(hook, tweet)
  end
end
