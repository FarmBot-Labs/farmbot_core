defmodule Farmbot.Repo do
  use Farmbot.Logger
  alias Farmbot.Repo.Snapshot
  use Ecto.Repo,
    otp_app: :farmbot,
    adapter: Application.get_env(:farmbot, __MODULE__)[:adapter]

  alias Farmbot.Asset.{
    Device,
    FarmEvent,
    Peripheral,
    Point,
    Regimen,
    Sensor,
    Sequence,
    Tool
  }

  def snapshot do
    results = Farmbot.Repo.all(Device) ++
    Farmbot.Repo.all(FarmEvent) ++
    Farmbot.Repo.all(Peripheral) ++
    Farmbot.Repo.all(Point) ++
    Farmbot.Repo.all(Regimen) ++
    Farmbot.Repo.all(Sensor) ++
    Farmbot.Repo.all(Sequence) ++
    Farmbot.Repo.all(Tool)

    struct(Snapshot, [data: results])
    |> Snapshot.md5()
  end
end
