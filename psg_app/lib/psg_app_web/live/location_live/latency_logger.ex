defmodule PsgAppWeb.LatencyLogger do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    {:ok, nil}
  end

  def log(latency) do
    GenServer.cast(__MODULE__, {:log, latency})
  end

  @impl true
  def handle_cast({:log, latency}, state) do
    # Append the latency to a file
    File.write!("latency.log", "#{latency}\n", [:append])
    {:noreply, state}
  end
end
