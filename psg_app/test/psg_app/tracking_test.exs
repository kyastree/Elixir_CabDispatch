defmodule PsgApp.TrackingTest do
  use PsgApp.DataCase

  alias PsgApp.Tracking

  describe "locations" do
    alias PsgApp.Tracking.Location

    import PsgApp.TrackingFixtures

    @invalid_attrs %{latitude: nil, longitude: nil}

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Tracking.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Tracking.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      valid_attrs = %{latitude: 120.5, longitude: 120.5}

      assert {:ok, %Location{} = location} = Tracking.create_location(valid_attrs)
      assert location.latitude == 120.5
      assert location.longitude == 120.5
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracking.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      update_attrs = %{latitude: 456.7, longitude: 456.7}

      assert {:ok, %Location{} = location} = Tracking.update_location(location, update_attrs)
      assert location.latitude == 456.7
      assert location.longitude == 456.7
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.update_location(location, @invalid_attrs)
      assert location == Tracking.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Tracking.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Tracking.change_location(location)
    end
  end
end
