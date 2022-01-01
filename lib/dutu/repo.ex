defmodule Dutu.Repo do
  use Ecto.Repo,
    otp_app: :dutu,
    adapter: Ecto.Adapters.Postgres
end
