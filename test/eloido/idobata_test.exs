defmodule Eloido.IdobataTest do
  use ExUnit.Case, async: true
  doctest Eloido.Idobata

  test "build_content/1" do
    tweet = %ExTwitter.Model.Tweet{
      created_at: "Wed Aug 27 13:08:45 +0000 2008",
      text: "Hello twitter!",
      user: %ExTwitter.Model.User{
        id_str: "12345",
        screen_name: "foo",
        profile_image_url_https: "http://example.com/images/photo99999"
      }
    }
    # FIXME: We need more better testing.
    # refute raise error
    Eloido.Idobata.build_content(tweet)
    assert true
  end
end
