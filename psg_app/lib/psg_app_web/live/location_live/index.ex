defmodule PsgAppWeb.LocationLive.Index do
  use PsgAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locations = []
    emqtt_opts = Application.get_env(:psg_app, :emqtt)
    {:ok, pid} = :emqtt.start_link(emqtt_opts)
    {:ok, _} = :emqtt.connect(pid)

    # 订阅相关主题
    {:ok, _, _} = :emqtt.subscribe(pid, "reports/#")

    {:ok, assign(socket, locations: locations, pid: pid, nearest_driver: nil, error_message: nil)}
  end


  @impl true
  def handle_info({:publish, packet}, socket) do
    handle_publish(parse_topic(packet), packet, socket)
  end


  def handle_publish(["reports", clientid, "location"], %{payload: payload}, socket) do
    timestamp_receive = :os.system_time(:millisecond)
    location = Jason.decode!(payload)
    latency = timestamp_receive - location["timestamp_send"]
    IO.puts("Latency: #{latency} milliseconds")
    PsgAppWeb.LatencyLogger.log(latency)

    location = Map.put(location, "client_id", clientid)
    location = Map.put(location, "latency", latency)

    locations = [location | socket.assigns.locations]
    {:noreply, assign(socket, locations: locations)}
  end

  @impl true
  def handle_event("request_taxi", %{"latitude" => lat, "longitude" => long}, socket) do
    start_time = :os.system_time(:millisecond)

    latitude = String.to_float(lat)
    longitude = String.to_float(long)

    if valid_coordinates?(latitude, longitude) do
      nearest_driver = find_nearest_driver(latitude, longitude, socket.assigns.locations)
      end_time = :os.system_time(:millisecond)
    latency = end_time - start_time
    IO.puts("Finding nearest driver latency: #{latency} milliseconds")

      IO.puts("Nearest driver: #{inspect(nearest_driver)}")

      {:noreply, assign(socket,
      passenger_location: %{latitude: latitude, longitude: longitude},
      nearest_driver: nearest_driver,
      error_message: nil)}
    else
      {:noreply, assign(socket, error_message: "Invalid coordinates. Please enter a valid latitude and longitude.")}
    end
  end

  defp find_nearest_driver(latitude, longitude, locations) do
    locations
    |> Enum.min_by(fn location ->
      Haversine.distance({latitude, longitude}, {location["latitude"], location["longitude"]})
    end)
  end

  defp parse_topic(%{topic: topic}) do
    String.split(topic, "/", trim: true)
  end

  defp valid_coordinates?(latitude, longitude) do
    latitude >= -90 and latitude <= 90 and
      longitude >= -180 and longitude <= 180
  end



end
