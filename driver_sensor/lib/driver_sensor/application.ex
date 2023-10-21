defmodule DriverSensor.Application do
  use Application

  def start(_type, _args) do
    children = for driver_id <- 1..5 do
      {lat, long} = generate_random_coordinates()
      Supervisor.child_spec({DriverSensor, [unique_id: driver_id, latitude: lat, longitude: long, name: :"DriverSensor_#{driver_id}"]}, id: :"DriverSensor_#{driver_id}")
    end

    opts = [strategy: :one_for_one, name: DriverSensor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp generate_random_coordinates do
    # You can modify these values based on the desired starting locations
    lat_min = 35.0  # Minimum latitude
    lat_max = 36.0  # Maximum latitude

    long_min = 139.0  # Minimum longitude
    long_max = 140.0  # Maximum longitude

    lat = lat_min + :rand.uniform() * (lat_max - lat_min)
    long = long_min + :rand.uniform() * (long_max - long_min)

    {lat, long}
  end
end
