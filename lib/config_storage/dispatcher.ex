defmodule Farmbot.System.ConfigStorage.Dispatcher do
  @moduledoc "Handles dispatching config changes."

  use GenStage

  def dispatch(%{value: value}, group, key) do
    GenStage.call(__MODULE__, {:dispatch, group, key, value})
  end

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    {
      :producer, [], [dispatcher: GenStage.BroadcastDispatcher]
    }
  end

  def handle_events(_, _, state) do
    {:noreply, [], state}
  end

  def handle_demand(_, state) do
    {:noreply, [], state}
  end

  def handle_call({:dispatch, group, key, val}, _, state) do
    Farmbot.System.Registry.dispatch(:config_storage, {group, key, val})
    {:reply, :ok, [{:config, group, key, val}], state}
  end
end
