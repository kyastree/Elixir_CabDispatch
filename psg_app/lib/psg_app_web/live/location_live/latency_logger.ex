defmodule PsgAppWeb.LatencyLogger do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, nil}
  end

  # Updated log function to accept both latency and timestamp
  def log(latency, timestamp_receive) do
    GenServer.cast(__MODULE__, {:log, latency, timestamp_receive})
  end

  @impl true
  def handle_cast({:log, latency, timestamp_receive}, state) do
    # Append the latency and timestamp to a file
    File.write!("latency.log", "#{timestamp_receive}, #{latency}\n", [:append])
    {:noreply, state}
  end
end
