defmodule Farmbot.System.ConfigStorage do
  @moduledoc "Repo for storing config data."

  # Sorry.
  # credo:disable-for-this-file

  use Ecto.Repo, otp_app: :farmbot, adapter: Application.get_env(:farmbot, __MODULE__)[:adapter]
  import Ecto.Query, only: [from: 2]
  alias Farmbot.System.ConfigStorage
  alias ConfigStorage.{
    Group, Config, BoolValue, FloatValue, StringValue,
    SyncCmd,
    PersistentRegimen,
  }

  alias Farmbot.Asset.Regimen

  @doc """
  Register a sync message from an external source.
  This is like a snippit of the changes that have happened.
  `sync_cmd`s should only be applied on `sync`ing.
  `sync_cmd`s are _not_ a source of truth for transactions that have been applied.
  Use the `Farmbot.Asset.Registry` for these types of events.
  """
  def register_sync_cmd(remote_id, kind, body) do
    SyncCmd.changeset(struct(SyncCmd, %{remote_id: remote_id, kind: kind, body: body}))
    |> insert!()
  end

  @doc "Destroy all sync cmds locally."
  def destroy_all_sync_cmds do
    delete_all(SyncCmd)
  end

  def all_sync_cmds do
    ConfigStorage.all(SyncCmd)
  end

  def destroy_sync_cmd(%SyncCmd{} = cmd) do
    ConfigStorage.delete(cmd)
  end

  @doc "Get all Persistent Regimens"
  def all_persistent_regimens do
    ConfigStorage.all(PersistentRegimen)
  end

  def persistent_regimens(%Regimen{id: id} = _regimen) do
    ConfigStorage.all(from pr in PersistentRegimen, where: pr.regimen_id == ^id)
  end

  def persistent_regimen(%Regimen{id: id, farm_event_id: fid} = _regimen) do
    fid || raise "Can't look up persistent regimens without a farm_event id."
    ConfigStorage.one(from pr in PersistentRegimen, where: pr.regimen_id == ^id and pr.farm_event_id == ^fid)
  end

  @doc "Add a new Persistent Regimen."
  def add_persistent_regimen(%Regimen{id: id, farm_event_id: fid} = _regimen, time) do
    fid || raise "Can't save persistent regimens without a farm_event id."
    PersistentRegimen.changeset(struct(PersistentRegimen, %{regimen_id: id, time: time, farm_event_id: fid}))
    |> ConfigStorage.insert()
  end

  def delete_persistent_regimen(%Regimen{id: regimen_id, farm_event_id: fid} = _regimen) do
    fid || raise "cannot delete persistent_regimen without farm_event_id"
    itm = ConfigStorage.one(from pr in PersistentRegimen, where: pr.regimen_id == ^regimen_id and pr.farm_event_id == ^fid)
    if itm, do: ConfigStorage.delete(itm), else: nil
  end

  def update_persistent_regimen_time(%Regimen{id: _regimen_id, farm_event_id: _fid} = regimen, %DateTime{} = time) do
    pr = persistent_regimen(regimen)
    if pr do
      pr = Ecto.Changeset.change pr, time: time
      ConfigStorage.update!(pr)
    else
      nil
    end
  end

  @doc "Please be careful with this. It uses a lot of queries."
  def get_config_as_map do
    groups = from(g in Group, select: g) |> all()

    Map.new(groups, fn group ->
      vals = from(b in Config, where: b.group_id == ^group.id, select: b) |> all()

      s =
        Map.new(vals, fn val ->
          [value] =
            Enum.find_value(val |> Map.from_struct(), fn {_key, _val} = f ->
              case f do
                {:bool_value_id, id} when is_number(id) ->
                  all(from(v in BoolValue, where: v.id == ^id, select: v.value))

                {:float_value_id, id} when is_number(id) ->
                  all(from(v in FloatValue, where: v.id == ^id, select: v.value))

                {:string_value_id, id} when is_number(id) ->
                  all(from(v in StringValue, where: v.id == ^id, select: v.value))

                _ ->
                  false
              end
            end)

          {val.key, value}
        end)

      {group.group_name, s}
    end)
  end

  def get_config_value(type, group_name, key_name) when type in [:bool, :float, :string] do
    __MODULE__
    |> apply(:"get_#{type}_value", [group_name, key_name])
    |> Map.fetch!(:value)
  end

  def get_config_value(type, _, _) do
    raise "Unsupported type: #{type}"
  end

  def update_config_value(type, group_name, key_name, value) when type in [:bool, :float, :string] do
    __MODULE__
    |> apply(:"get_#{type}_value", [group_name, key_name])
    |> Ecto.Changeset.change(value: value)
    |> update!()
    |> Farmbot.System.ConfigStorage.Dispatcher.dispatch(group_name, key_name)
  end

  def update_config_value(type, _, _, _) do
    raise "Unsupported type: #{type}"
  end

  def get_bool_value(group_name, key_name) do
    group_id = get_group_id(group_name)

    case from(
           c in Config,
           where: c.group_id == ^group_id and c.key == ^key_name,
           select: c.bool_value_id
         )
         |> all() do
      [type_id] ->
        [val] = from(v in BoolValue, where: v.id == ^type_id, select: v) |> all()
        val

      [] ->
        raise "no such key #{key_name}"
    end
  end

  def get_float_value(group_name, key_name) do
    group_id = get_group_id(group_name)

    [type_id] =
      from(
        c in Config,
        where: c.group_id == ^group_id and c.key == ^key_name,
        select: c.float_value_id
      )
      |> all()

    [val] = from(v in FloatValue, where: v.id == ^type_id, select: v) |> all()
    val
  end

  def get_string_value(group_name, key_name) do
    group_id = get_group_id(group_name)

    [type_id] =
      from(
        c in Config,
        where: c.group_id == ^group_id and c.key == ^key_name,
        select: c.string_value_id
      )
      |> all()

    [val] = from(v in StringValue, where: v.id == ^type_id, select: v) |> all()
    val
  end

  defp get_group_id(group_name) do
    [group_id] = from(g in Group, where: g.group_name == ^group_name, select: g.id) |> all()
    group_id
  end
end
