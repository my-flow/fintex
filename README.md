FinTex
======

[![Build Status](https://travis-ci.org/my-flow/fintex.svg?branch=master)](https://travis-ci.org/my-flow/fintex)
[![Coverage Status](https://coveralls.io/repos/my-flow/fintex/badge.svg?branch=master)](https://coveralls.io/r/my-flow/fintex?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/fintex.svg)](https://hex.pm/packages/fintex)

An Elixir-based client library for **HBCI 2.2** and **FinTS 3.0**.

In 1995 German banks announced a common online banking standard called *Homebanking Computer Interface* (HBCI). In 2003 they published the next generation and named it *Financial Transaction Services* (FinTS). Today more than 2,000 German banks support HBCI/FinTS.

This client library supports both APIs, HBCI 2.2 and FinTS 3.0. It can be used to read the balance of a bank account, receive an account statement, and make a SEPA payment using PIN/TAN.


# Installation
Include a dependency in your `mix.exs`:
```elixir
deps: [
  {:fintex, "~> 0.2.0"}
]
```
To use FinTex modules, add `use FinTex` to the top of each module you plan on referencing FinTex from.

# Usage
First and foremost you need bank-specific connection data of the bank you try to connect to (payment industry jargon: *[FinBanks](https://subsembly.com/de/finbanks.html)*). A full list of connection data can be obtained from the [official DK website](http://www.hbci-zka.de/institute/institut_auswahl.htm). Please keep in mind that these connection details are subject to change.
```elixir
use FinTex
bank = %{
  blz: "12345678",            # 8 digits bank code
  url: "https://example.org", # URL of the bank server
  version: "300"              # API version
}
```

## Ping
Some, but not all, banks support the “anonymous login” feature, so you can send a ping request:
```elixir
FinTex.ping(bank)
```

## Initialize the dialog
In order to authenticate , you need credentials to a real-life bank account (usually login and PIN). Note that repeated failed attempts to log in might cause the bank to block the bank account.
```elixir
credentials = %{
  login: "username",
  pin: "secret"
}
f = FinTex.new(bank, credentials)
# %FinTex{bank: %FinTex.User.FinBank{blz: "12345678", url: "https://example.org", version: "300"}, client_system_id: "321", tan_scheme_sec_func: "999"}
```

## Retrieve all bank accounts
Retrieve account-specific data, such as an account's balance:
```elixir
FinTex.accounts!(f, credentials) |> Enum.to_list # retrieve a list of bank accounts
```

## Retrieve all transactions of a bank account
Request all transactions of one of the bank accounts:
```elixir
FinTex.transactions!(f, credentials, account) |> Enum.to_list # retrieve a list of transactions
```

## Make a SEPA payment
A bank account contains a list of supported TAN schemes each of which can be used to make a SEPA payment. Pick a sender bank account (see above), add the receiver bank account (IBAN/BIC) and define the details:

```elixir
payment = %FinTex.Model.Payment{
  sender_account: %FinTex.Model.Account{
    iban:  "DE89370400440532013000",
    bic:   "COBADEFFXXX",
    owner: "John Doe"
  },
  receiver_account: %FinTex.Model.Account{
    iban:  "FR1420041010050500013M02606",
    bic:   "ABNAFRPPXXX",
    owner: "Jane Doe"
  },
  amount: "1.00",
  currency: "EUR",
  purpose: "A new test payment",
  tan_scheme: %FinTex.Model.TANScheme{
    sec_func: "921"
  }
}

FinTex.initiate_payment(f, credentials, payment)
```

## Error handling
Most of the functions in this module return `{:ok, result}` in case of success, `{:error, reason}` otherwise. Those functions are also followed by a variant that ends with `!` which takes the same arguments but which returns the result (without the `{:ok, result}` tuple) in case of success or raises an exception in case it fails.

## SSL hostname verification & path validation
In order to prevent man-in-the-middle attacks it is recommended to enable **hostname verification** of the bank server's SSL certificate. This security feature verifies that the server's hostname matches the common name (CN) of the server's SSL certificate.
In addition the **path validation** feature checks the bank server's SSL certificate against a list of trusted Certificate Authorities (CAs). Where this list is located depends on the local operating system, e.g. on Ubuntu a concatenated single-file list of certificates is available at ``/etc/ssl/certs/ca-certificates.crt``.
An example of how to set up both security features is included in [config/config.exs](config/config.exs).

## Proxy Settings
Find sample configurations in [config/config.exs](config/config.exs) that show how to set up proxy authentication and SOCKS5.

# Documentation
API documentation is available at [http://hexdocs.pm/fintex](http://hexdocs.pm/fintex).


# Specification

For exact information please refer to the [German version of the specification](http://www.hbci-zka.de/spec/spezifikation.htm). There is also an [unauthorized English translation](http://www.hbci-zka.de/english/specification/engl_2_2.htm).


# Copyright & License

Copyright (c) 2015 [Florian J. Breunig](http://www.my-flow.com)

Licensed under MIT, see LICENSE file.
