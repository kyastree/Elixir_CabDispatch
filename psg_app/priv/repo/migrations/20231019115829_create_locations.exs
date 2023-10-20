defmodule PsgApp.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :latitude, :float
      add :longitude, :float

      timestamps()
    end
  end
end
