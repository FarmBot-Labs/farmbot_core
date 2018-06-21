defmodule Farmbot.Logger do
  @moduledoc """
  Log messages to Farmot endpoints.
  """
  alias Farmbot.Logger.Repo
  import Ecto.Query, only: [from: 2]

  @doc "Send a debug message to log endpoints"
  defmacro debug(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :debug, verbosity, message, meta)
    end
  end

  @doc "Send an info message to log endpoints"
  defmacro info(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :info, verbosity, message, meta)
    end
  end

  @doc "Send an busy message to log endpoints"
  defmacro busy(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :busy, verbosity, message, meta)
    end
  end

  @doc "Send an success message to log endpoints"
  defmacro success(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :success, verbosity, message, meta)
    end
  end

  @doc "Send an warn message to log endpoints"
  defmacro warn(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :warn, verbosity, message, meta)
    end
  end

  @doc "Send an error message to log endpoints"
  defmacro error(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :error, verbosity, message, meta)
    end
  end

  @doc false
  defmacro fun(verbosity, message, meta \\ []) do
    quote bind_quoted: [verbosity: verbosity, message: message, meta: meta] do
      Farmbot.Logger.dispatch_log(__ENV__, :fun, verbosity, message, meta)
    end
  end

  @doc false
  defmacro __using__(_) do
    quote do
      alias Farmbot.Logger
      import Farmbot.Logger, only: [
        debug: 3,
        debug: 2,
        info: 3,
        info: 2,
        busy: 3,
        busy: 2,
        success: 3,
        success: 2,
        warn: 3,
        warn: 2,
        error: 3,
        error: 2,
        fun: 2,
        fun: 3
      ]
    end
  end

  def insert_log!(%Farmbot.Log{} = log) do
    Farmbot.Log.changeset(log, %{})
    |> Repo.insert!()
  end

  def clear_log(%Farmbot.Log{} = log) do
    Repo.delete!(log)
  end

  def get_logs(amnt) do
    from(Farmbot.Log, limit: ^amnt)
    |> Repo.all()
  end

  @doc false
  def dispatch_log(%Macro.Env{} = env, level, verbosity, message, meta)
  when level in [:info, :debug, :busy, :warn, :success, :error, :fun]
  and  is_number(verbosity)
  and  is_binary(message)
  and  is_list(meta)
  do
    fun = case env.function do
      {fun, ar} -> "#{fun}/#{ar}"
      nil -> "no_function"
    end

    struct(Farmbot.Log, [
      level: level,
      verbosity: verbosity,
      message: message,
      meta: Map.new(meta),
      function: fun,
      file: env.file,
      line: env.line,
      module: env.module])
    |> dispatch_log()
  end

  def dispatch_log(%Farmbot.Log{} = log) do
    log
    |> insert_log!()
    |> elixir_log()
  end

  def format_logs do
    RingLogger.get()
    |> Enum.map(fn({level, {_logger, message, timestamp_tup, _meta}}) ->
      # {{year, month, day}, {hour, minute, second, _}} = timestamp_tup
      timestamp  = Timex.to_datetime(timestamp_tup) |> DateTime.to_iso8601()
      reg = ~r/\x1B\[[0-?]*[ -\/]*[@-~]/

      "[#{level} #{timestamp}] - #{Regex.replace(reg, to_string(message), "")}"
    end)
  end

  defp elixir_log(%Farmbot.Log{} = log) do
    # todo fix time
    logger_meta = [function: log.function, file: log.file, line: log.line, module: log.module]
    logger_level = if log.level in [:info, :debug, :warn, :error], do: log.level, else: :info
    Elixir.Logger.bare_log(logger_level, log, logger_meta)
    log
  end
end