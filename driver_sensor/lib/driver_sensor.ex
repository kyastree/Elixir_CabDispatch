defmodule DriverSensor do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    emqtt_opts = %{
      host: '192.168.215.2',
      port: 1883,
      clientid: "driver_sensor",
      clean_start: false,
      name: :emqtt
    }
    interval = 5_000  # Set the interval to 10 seconds (10000 milliseconds)
    report_topic = "reports/#{emqtt_opts[:clientid]}/location"
    {:ok, pid} = :emqtt.start_link(emqtt_opts)
    st = %{
      interval: interval,
      timer: nil,
      report_topic: report_topic,
      pid: pid,
      latitude: 35.6895, # Starting latitude for Tokyo
      longitude: 139.6917 # Starting longitude for Tokyo
    }

    {:ok, set_timer(st), {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = st) do
    {:ok, _} = :emqtt.connect(pid)

    emqtt_opts = Application.get_env(:weather_sensor, :emqtt)
    clientid = emqtt_opts[:clientid]
    {:ok, _, _} = :emqtt.subscribe(pid, {"commands/#{clientid}/set_interval", 1})
    {:noreply, st}
  end

  def handle_info(:tick, state) do
    new_state = report_location(state)
    {:noreply, set_timer(new_state)}
end


  def handle_info({:publish, publish}, st) do
    handle_publish(parse_topic(publish), publish, st)
  end

  defp handle_publish(["commands", _, "set_interval"], %{payload: payload}, st) do
    new_st = %{st | interval: String.to_integer(payload)}
    {:noreply, set_timer(new_st)}
  end

  defp handle_publish(_, _, st) do
    {:noreply, st}
  end

  defp parse_topic(%{topic: topic}) do
    String.split(topic, "/", trim: true)
  end

  defp set_timer(st) do
    if st.timer do
      Process.cancel_timer(st.timer)
    end
    timer = Process.send_after(self(), :tick, st.interval)
    %{st | timer: timer}
  end

  defp report_location(%{pid: pid, report_topic: topic, latitude: lat, longitude: long} = state) do
    # Random walk logic: adding a small random offset to latitude and longitude
    new_latitude = lat + (:rand.uniform(2) - 1) * 0.01
    new_longitude = long + (:rand.uniform(2) - 1) * 0.01

    # Adding a timestamp to the payload
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    location = %{latitude: new_latitude, longitude: new_longitude, timestamp: timestamp}

    payload = Jason.encode!(location)
    :emqtt.publish(pid, topic, payload)

    # Updating the state with the new location
    %{state | latitude: new_latitude, longitude: new_longitude}
  end
end
