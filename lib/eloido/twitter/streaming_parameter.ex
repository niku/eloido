defmodule Eloido.Twitter.StreamingParameter do
  @moduledoc """
  Parameter helpers for Twitter Streaming
  """

  @doc """
  Builds string to keyword list as parameter for a twitter streaming.

  ## Examples

  iex> Eloido.Twitter.StreamingParameter.build("", "")
  []

  iex> Eloido.Twitter.StreamingParameter.build("foo", "")
  [track: "foo"]

  iex> Eloido.Twitter.StreamingParameter.build("", "1234")
  [follow: "1234"]

  iex> Eloido.Twitter.StreamingParameter.build("foo", "1234")
  [track: "foo", follow: "1234"]
  """
  @spec build(String.t, String.t) :: [] | [track: String.t] | [follow: String.t] | [track: String.t, follow: String.t]
  def build("", ""), do: []
  def build(track, ""), do: [track: track]
  def build("", follow), do: [follow: follow]
  def build(track, follow), do: [track: track, follow: follow]
end
