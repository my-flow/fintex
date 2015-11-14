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
  {:fintex, "~> 0.0.1"}
  {:ibrowse, tag: "v4.1.1", github: "cmullaparthi/ibrowse"},
  {:xml_builder, commit: "1e381db0b7d289ee18c2f7fd682d8e47215a141c", github: "joshnuss/xml_builder"}
]
```
To use FinTex modules, add `use FinTex` to the top of each module you plan on referencing FinTex from.

# Usage
First and foremost you need bank-specific connection data of the bank you try to connect to (payment industry jargon: *[FinBanks](https://subsembly.com/de/finbanks.html)*). A full list of connection data can be obtained from the [official DK website](http://www.hbci-zka.de/institute/institut_auswahl.htm). Please keep in mind that these connection details are subject to change.
```elixir
use FinTex
bank = %FinTex.User.FinBank{
  blz: "12345678",            # 8 digits bank code
  url: "https://example.org", # URL of the bank server
  version: "300"              # API version
}
```
Feel free to instead implement the [Bank protocol](http://hexdocs.pm/fintex/FinTex.User.Bank.html) for your own struct, e.g., a custom data model.

## Ping
Some, but not all, banks support the “anonymous login” feature, so you can send a ping request:
```elixir
ping(bank)
```

## Retrieve all bank accounts
In order to retrieve account-specific data (such as an account's balance), you need credentials for a real-life bank account (usually login and PIN). Note that repeated failed attempts to log in might cause the bank to block the bank account.
```elixir
credentials = %FinTex.User.FinCredentials{
  login: "username",
  pin: "secret"
}
accounts(bank, credentials) |> Enum.to_list # retrieve a list of bank accounts
```
Feel free to instead implement the [Credentials protocol](http://hexdocs.pm/fintex/FinTex.User.Credentials.html) for your own struct.

## Retrieve all transactions of a bank account
Request all transactions of one of the bank accounts:
```elixir
transactions(bank, credentials, account) |> Enum.to_list # retrieve a list of transactions
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

initiate_payment(bank, credentials, payment)
```


# Documentation

API documentation is available at [http://hexdocs.pm/fintex](http://hexdocs.pm/fintex).


# Specification

For exact information please refer to the [German version of the specification](http://www.hbci-zka.de/spec/spezifikation.htm). There is also an [unauthorized English translation](http://www.hbci-zka.de/english/specification/engl_2_2.htm).


# Copyright & License

Copyright (c) 2015 [Florian J. Breunig](http://www.my-flow.com)

Licensed under MIT, see LICENSE file.
