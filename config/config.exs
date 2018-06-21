use Mix.Config

# Configure Farmbot Behaviours.
config :farmbot, :behaviour,
  firmware_handler: Farmbot.Firmware.StubHandler,
  json_parser: Farmbot.JSON.JasonParser

config :farmbot, :farmware,
  first_part_farmware_manifest_url: "https://raw.githubusercontent.com/FarmBot-Labs/farmware_manifests/master/manifest.json"

config :farmbot,
  expected_fw_versions: ["6.4.0.F", "6.4.0.R", "6.4.0.G"],
  default_server: "https://my.farm.bot",
  default_currently_on_beta: String.contains?(to_string(:os.cmd('git rev-parse --abbrev-ref HEAD')), "beta"),
  firmware_io_logs: false,
  farm_event_debug_log: false

config :farmbot, :farmware,
  first_part_farmware_manifest_url: nil

config :farmbot, ecto_repos: [Farmbot.Config.Repo, Farmbot.Logger.Repo, Farmbot.Asset.Repo]

config :farmbot, Farmbot.Config.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._configs.sqlite3",
  priv: "priv/config",
  pool_size: 1

config :farmbot, Farmbot.Logger.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._logs.sqlite3",
  priv: "priv/logger",
  pool_size: 1

config :farmbot, Farmbot.Asset.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._assets.sqlite3",
  priv: "priv/asset",
  pool_size: 1
