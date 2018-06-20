defmodule Farmbot.Core do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    children = [
      {Farmbot.System.Registry,                 [] },
      {Farmbot.System.ConfigStorage,            [] },
      {Farmbot.System.ConfigStorage.Dispatcher, [] },
      {Farmbot.Logger.Supervisor,               [] },
      {Farmbot.Firmware.Supervisor,             [] },
      {Farmbot.BotState.Supervisor,             [] },
      {Farmbot.Repo.Supervisor,                 [] },
      # {Farmbot.Farmware.Supervisor,             [] },
      {Farmbot.Regimen.NameProvider,            [] },
      {Farmbot.FarmEvent.Supervisor,            [] },
      {Farmbot.Regimen.Supervisor,              [] },
    ]
    Supervisor.init(children, [strategy: :one_for_one])
  end
end
