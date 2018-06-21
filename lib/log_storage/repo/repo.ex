defmodule Farmbot.Logger.Repo do
  use Ecto.Repo,
    otp_app: :farmbot_core,
    adapter: Application.get_env(:farmbot_core, __MODULE__)[:adapter]
end
