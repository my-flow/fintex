defmodule FinTex.Model.PaymentType do
  @moduledoc false

  # @moduledoc """
  # The following fields are public:
  #   * `allowed_recipients`  - List of account IDs. Payment recipient must be one of these accounts.
  #   * `max_purpose_length`  - Maximum string length of purpose text
  #   * `supported_text_keys` - List of supported DTA text keys
  #   * `min_scheduled_date`  - Earliest scheduled date
  #   * `max_scheduled_date`  - Latest scheduled date
  #   * `can_be_recurring`    - Is `true` if the payment supports standing orders
  #   * `can_be_scheduled`    - Is `true` if the payment can be scheduled to be executed at a future date
  # """

  defstruct [
    :max_purpose_length,
    :supported_text_keys,
    :min_scheduled_date,
    :max_scheduled_date,
    allowed_recipients: [],
    can_be_recurring: false,
    can_be_scheduled: false,
  ]

  @type t :: %__MODULE__{}
end
