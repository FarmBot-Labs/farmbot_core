defmodule Farmbot.Core do
  use Supervisor

  def start(_, _), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    children = [
      {Farmbot.System.Registry,                 [] },
      {Farmbot.Logger.Supervisor,               [] },
      {Farmbot.Config.Supervisor,               [] },
      {Farmbot.Asset.Supervisor,                [] },
      {Farmbot.Firmware.Supervisor,             [] },
    ]
    Supervisor.init(children, [strategy: :one_for_one])
  end
end
