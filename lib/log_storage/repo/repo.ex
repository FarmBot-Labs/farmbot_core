defmodule Farmbot.Logger.Repo do
  use Ecto.Repo,
    otp_app: :farmbot,
    adapter: Application.get_env(:farmbot, __MODULE__)[:adapter]
end