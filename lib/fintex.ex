defmodule FinTex do
  @moduledoc File.read!("README.md")

  defmacro __using__(_) do
    quote do
      Application.put_env(:vex, :sources, [FinTex.Validator, Vex.Validators])
      import FinTex.Command.Facade
    end
  end
end
