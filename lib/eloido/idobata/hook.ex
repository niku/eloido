defmodule Eloido.Idobata.Hook do
  @moduledoc """
  Representation of a idobata custom hook
  """

  defstruct source: "", format: nil, image: nil
  @type t :: %__MODULE__{source: String.t, format: nil|:html, image: nil|binary()}

  @doc """
  Encodes struct to a query

  ## Examples

  iex> Eloido.Idobata.Hook.encode_query(%Eloido.Idobata.Hook{source: "foobar"})
  "source=foobar"

  iex> Eloido.Idobata.Hook.encode_query(%Eloido.Idobata.Hook{source: "foobar", format: :html})
  "format=html&source=foobar"

  iex> Eloido.Idobata.Hook.encode_query(%Eloido.Idobata.Hook{source: "foobar", format: :html, image: <<71, 73, 70, 56, 57, 97, 1>>})
  "format=html&image=GIF89a%01&source=foobar"

  """
  @spec encode_query(t) :: String.t
  def encode_query(hook = %Eloido.Idobata.Hook{}) do
    Map.from_struct(hook)
    |> Enum.filter(fn {_, v} -> v end)
    |> URI.encode_query
  end
end
