defmodule Farmbot.Core do
  @moduledoc """
  Core Farmbot Services.
  This includes Logging, Configuration, Asset management and Firmware.
  """
  use Supervisor

  @doc false
  def start(_, _), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  @doc false
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    children = [
      {Farmbot.Registry,               [] },
      {Farmbot.Logger.Supervisor,      [] },
      {Farmbot.Config.Supervisor,      [] },
      {Farmbot.Asset.Supervisor,       [] },
      {Farmbot.Firmware.Supervisor,    [] },
      {Farmbot.BotState,               [] },
      {Farmbot.CeleryScript.Scheduler, [] }
    ]
    Supervisor.init(children, [strategy: :one_for_one])
  end
end
