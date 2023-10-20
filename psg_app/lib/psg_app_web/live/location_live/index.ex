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

    {:ok, assign(socket, locations: locations, pid: pid)}
  end

  @impl true
  def handle_info({:publish, packet}, socket) do
    handle_publish(parse_topic(packet), packet, socket)
  end

  defp handle_publish(["reports", clientid, "location"], %{payload: payload}, socket) do
    timestamp_receive = :os.system_time(:millisecond)
    location = Jason.decode!(payload)
    latency = timestamp_receive - location["timestamp_send"]
    IO.puts("Latency: #{latency} milliseconds")
    # Adding client_id to the location map
    location = Map.put(location, "client_id", clientid)
    location = Map.put(location, "latency", latency)

    locations = [location | socket.assigns.locations]
    {:noreply, assign(socket, locations: locations)}
  end



  defp parse_topic(%{topic: topic}) do
    String.split(topic, "/", trim: true)
  end


end
