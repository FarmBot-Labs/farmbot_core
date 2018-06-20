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

config :farmbot, data_path: "tmp/"

config :farmbot, ecto_repos: [Farmbot.System.ConfigStorage, Farmbot.Logger.Store, Farmbot.Repo]

config :farmbot, Farmbot.System.ConfigStorage,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._config_storage.sqlite3",
  pool_size: 1

config :farmbot, Farmbot.Logger.Store,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._logger_store.sqlite3",
  pool_size: 1

config :farmbot, Farmbot.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: "._repo.sqlite3",
  pool_size: 1
