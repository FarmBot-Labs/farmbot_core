defmodule Farmbot.Asset.Repo.Supervisor do
  @moduledoc false

  use Supervisor

  @doc false
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, [name: __MODULE__])
  end

  @doc false
  def init([]) do
    children = [
      {Farmbot.Asset.Repo, []},
    ]
    Supervisor.init(children, [strategy: :one_for_all])
  end
end
