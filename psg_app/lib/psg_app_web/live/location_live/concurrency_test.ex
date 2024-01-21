
defmodule ConcurrencyTest do
  def distance_to_origin(x, y), do: :math.sqrt(x * x + y * y)

  def test_concurrency(num_tasks) do
    tasks = 1..num_tasks
    |> Enum.map(fn _ ->
        Task.async(
          fn ->
            x = :rand.uniform(1000)
            y = :rand.uniform(1000)
            distance_to_origin(x, y)
          end) end)
    |> Enum.map(&Task.await/1)

    IO.puts("Schedulers:#{:erlang.system_info(:schedulers_online)}")
  end

end

ConcurrencyTest.test_concurrency(500)

IO.inspect(:erlang.system_info(:schedulers_online))
