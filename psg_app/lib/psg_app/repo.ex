defmodule PsgApp.Repo do
  use Ecto.Repo,
    otp_app: :psg_app,
    adapter: Ecto.Adapters.Postgres
end
