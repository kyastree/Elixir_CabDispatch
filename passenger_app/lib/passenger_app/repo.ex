defmodule PassengerApp.Repo do
  use Ecto.Repo,
    otp_app: :passenger_app,
    adapter: Ecto.Adapters.Postgres
end
