defmodule Event do
  defstruct [:type, :payload, :timestamp]

  def new_event(type, payload) do
    %MyApp.Event{
      type: type,
      payload: payload,
      timestamp: DateTime.utc_now()
    }
  end

  def serialize(event) do
    Jason.encode!(event)
  end

  def deserialize(json) do
    case Jason.decode(json) do
      {:ok, data} -> {:ok, struct(MyApp.Event, data)}
      {:error, _} = error -> error
    end
  end


end
