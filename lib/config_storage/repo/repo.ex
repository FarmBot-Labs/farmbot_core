defmodule Farmbot.Config.Repo do
  @moduledoc "Repo for storing config data."
  use Ecto.Repo, otp_app: :farmbot, adapter: Application.get_env(:farmbot, __MODULE__)[:adapter]
end
