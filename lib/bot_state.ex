defmodule Farmbot.BotState do
  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    {:consumer, new_state(), [subscribe_to: [Farmbot.Firmware]]}
  end

  def handle_events(events, _from, state) do
    state = Enum.reduce(events, state, &handle_event(&1, &2))
    Farmbot.Registry.dispatch(__MODULE__, state)
    {:noreply, [], state}
  end

  def handle_event({:informational_settings, data}, state) do
    new_informational_settings = Map.merge(state.informational_settings, data)
    %{state | informational_settings: new_informational_settings}
  end

  def handle_event({:mcu_params, data}, state) do
    new_mcu_params = Map.merge(state.mcu_params, data)
    %{state | mcu_params: new_mcu_params}
  end

  def handle_event(event, state) do
    IO.inspect event, label: "unhandled event"
    state
  end

  defp new_state do
    %{
      informational_settings: %{},
      mcu_params: %{}
    }
  end
end
