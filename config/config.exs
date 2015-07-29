# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, :console,
  level: :debug,
  format: "$message\n",
  metadata: [:user_id]


# SSL hostname verification and path validation

# config :fintex, :ssl_options,
#   verify: :verify_peer,
#   cacertfile: Path.join(["/", "etc", "ssl", "certs", "ca-certificates.crt"]) |> to_char_list,
#   verify_fun: {&:ssl_verify_hostname.verify_fun/3, []},
#   depth: 99


# Sample configuration with proxy authentication:

# config :fintex, :ibrowse,
#     [
#         proxy_host: '192.168.178.20',
#         proxy_port: 8080
#     ]
