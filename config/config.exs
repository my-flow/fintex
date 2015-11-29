# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, :console,
  level: :debug,
  format: "$message\n",
  metadata: [:user_id]


# HTTP parameters

config :fintex, :http_options,
  [
    timeout: 10_000
  ]


# SSL hostname verification and path validation

# config :fintex, :ssl_options,
#   [
#     verify: :verify_peer,
#     cacertfile: Path.join(["/", "etc", "ssl", "certs", "ca-certificates.crt"]) |> to_char_list,
#     verify_fun: {&:ssl_verify_hostname.verify_fun/3, []},
#     depth: 99
#   ]


# Sample configuration with proxy authentication:

# config :fintex, :ibrowse,
#   [
#     proxy_user: 'XXXXX',
#     proxy_password: 'XXXXX',
#     proxy_host: 'proxy',
#     proxy_port: 8080
#   ]


# Sample configuration with SOCKS5:
#
# config :fintex, :ibrowse,
#   [
#     socks5_user: 'user4321',
#     socks5_pass: 'pass7654',
#     socks5_host: '127.0.0.1',
#     socks5_port: 5335
#   ]
