defmodule PsgAppWeb.LocationLive.LocationManager do
  use GenServer
  def start_link(initial_state \\ %{drivers: [], passenger: nil, nearest_driver: nil}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @spec init(any()) :: {:ok, any()}
  def init(initial_state) do
    {:ok, initial_state}
  end

  # 当添加新司机坐标时更新状态
  def handle_cast({:new_driver_location, driver_location}, state) do
    drivers = [driver_location | state.drivers]
    # 检查是否达到100个坐标，并执行调度任务
    if length(drivers) == 100 do
      passenger_location = generate_passenger_location([])
      nearest_driver = find_nearest_driver(passenger_location.latitude, passenger_location.longitude, drivers)
      new_state = %{state | drivers: [], passenger: passenger_location, nearest_driver: nearest_driver}
      IO.puts("THE ONE IS #{new_state}")
      {:noreply, new_state}
    else
      {:noreply, %{state | drivers: drivers}}
    end
  end

  defp generate_passenger_location(opts) do
    latitude = Keyword.get(opts, :latitude, 35.6895)
    longitude = Keyword.get(opts, :longitude, 139.6917)
    new_latitude = latitude + (:rand.uniform(2) - 1) * 0.01
    new_longitude = longitude + (:rand.uniform(2) - 1) * 0.01

    %{latitude: new_latitude, longitude: new_longitude}
  end


  defp find_nearest_driver(latitude, longitude, locations) do
    locations
    |> Enum.min_by(fn location ->
      Haversine.distance({latitude, longitude}, {location["latitude"], location["longitude"]})
    end)
  end

  def get_latest_dispatch() do
    GenServer.call(__MODULE__, :get_latest_dispatch)
  end

  def handle_call(:get_latest_dispatch, _from, state) do
    {:reply, {state.passenger, state.nearest_driver}, state}
  end

#  def handle_cast({:update_nearest_driver, nearest_driver}, state) do
#    {:noreply, %{state | nearest_driver: nearest_driver}}
#  end


end
