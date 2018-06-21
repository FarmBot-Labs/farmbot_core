defmodule FarmbotNg.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  @version Path.join(__DIR__, "VERSION") |> File.read!() |> String.trim()

  defp commit do
    System.cmd("git", ~w"rev-parse --verify HEAD") |> elem(0) |> String.trim()
  end

  defp arduino_commit do
    opts = [cd: "c_src/farmbot-arduino-firmware"]

    System.cmd("git", ~w"rev-parse --verify HEAD", opts)
    |> elem(0)
    |> String.trim()
  end

  def project do
    [
      app: :farmbot,
      description: "The Brains of the Farmbot Project",
      elixir: "~> 1.6",
      # package: package(),
      make_clean: ["clean"],
      make_env: make_env(),
      compilers: [:elixir_make] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      version: @version,
      target: @target,
      commit: commit(),
      arduino_commit: arduino_commit(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:mix],
        flags: []
      ],
      preferred_cli_env: [
        test: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.circle": :test
      ],
      source_url: "https://github.com/Farmbot/farmbot_os",
      homepage_url: "http://farmbot.io",
      # docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Farmbot.Core, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4.1", runtime: false},
      {:gen_stage, "~> 0.12"},
      {:ecto, "~> 2.2.2"},
      {:sqlite_ecto2, "~> 2.2.1"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 3.3"},
      {:nerves_uart, "~> 1.2"},
      {:ring_logger, "~> 0.4.1"}
    ]
  end

  defp make_env do
    case System.get_env("ERL_EI_INCLUDE_DIR") do
      nil ->
        %{
          "ERL_EI_INCLUDE_DIR" =>
            Path.join([:code.root_dir(), "usr", "include"]),
          "ERL_EI_LIBDIR" => Path.join([:code.root_dir(), "usr", "lib"]),
          "MIX_TARGET" => @target
        }

      _ ->
        %{}
    end
  end
end
