defmodule PsgApp.Tracking.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :latitude, :float
    field :longitude, :float

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:latitude, :longitude])
    |> validate_required([:latitude, :longitude])
  end
end
