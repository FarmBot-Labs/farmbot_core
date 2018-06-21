defmodule Farmbot.Logger.TestConsumer do
  use GenStage

  @min_demand 1
  @max_demand 4

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    state = %{producer: Farmbot.Logger, subscription: nil}
    GenStage.async_subscribe(
      self(),
      to: state.producer,
      min_demand: @min_demand,
      max_demand: @max_demand
    )
    {:consumer, state}
  end

  def handle_info(:init_ask, %{subscription: subscription} = state) do
    GenStage.ask(subscription, @max_demand)
    {:noreply, [], state}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  def handle_subscribe(:producer, _opts, from, state) do
    {:automatic, Map.put(state, :subscription, from)}
  end

  def handle_events(events, _from, state) do
    tag = make_ref()
    for log <- events do
      IO.inspect log, label: "HEY: #{inspect tag}"
    end
    GenStage.ask(state.subscription, @max_demand)
    {:noreply, [], state}
  end
end
