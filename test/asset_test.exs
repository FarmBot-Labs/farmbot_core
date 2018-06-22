defmodule Farmbot.AssetTest do
  use ExUnit.Case, async: false
  alias Farmbot.Asset
  alias Asset.{
    SyncCmd,
    Sequence
  }
  alias Asset.Repo.Snapshot.Diff

  test "registers sync commands and syncs" do
    id = 100
    refute Asset.get_sequence_by_id(id)
    Farmbot.Registry.subscribe()
    seq = %Sequence{
      name: "test sequence",
      kind: "sequence",
      args: %{},
      body: [],
      id: id
    }
    %SyncCmd{} = sync_cmd = Asset.register_sync_cmd(id, "Sequence", seq)
    assert sync_cmd.remote_id == id
    assert sync_cmd.kind == "Sequence"
    assert sync_cmd.body == seq
    Asset.fragment_sync()
    Farmbot.Registry.drop_pattern(Farmbot.BotState, self())
    Farmbot.Registry.drop_pattern(Farmbot.Config, self())
    from_db = Asset.get_sequence_by_id(id)
    assert_receive {Farmbot.Registry, {Asset, {:sync_status, :syncing}}}
    assert_receive {Farmbot.Registry, {Asset, {:sync_diff, %Diff{additions: [^from_db]}}}}
    assert_receive {Farmbot.Registry, {Asset, {:sync_status, :synced}}}
  end
end
