defmodule PsgApp.TrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PsgApp.Tracking` context.
  """

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        latitude: 120.5,
        longitude: 120.5
      })
      |> PsgApp.Tracking.create_location()

    location
  end
end
