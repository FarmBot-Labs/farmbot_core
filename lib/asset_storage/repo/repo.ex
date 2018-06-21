defmodule Farmbot.Asset.Repo do
  use Farmbot.Logger
  alias Farmbot.Asset.Repo.Snapshot
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
    results = Farmbot.Asset.Repo.all(Device) ++
    Farmbot.Asset.Repo.all(FarmEvent) ++
    Farmbot.Asset.Repo.all(Peripheral) ++
    Farmbot.Asset.Repo.all(Point) ++
    Farmbot.Asset.Repo.all(Regimen) ++
    Farmbot.Asset.Repo.all(Sensor) ++
    Farmbot.Asset.Repo.all(Sequence) ++
    Farmbot.Asset.Repo.all(Tool)

    struct(Snapshot, [data: results])
    |> Snapshot.md5()
  end
end
