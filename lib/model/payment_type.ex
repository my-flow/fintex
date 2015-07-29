defmodule FinTex.Model.PaymentType do
  @moduledoc false

  # @moduledoc """
  # The following fields are public:
  #   * `max_purpose_length`  - Maximum string length of purpose text
  #   * `supported_text_keys` - List of supported DTA text keys
  #   * `min_scheduled_date`  - Earliest scheduled date
  #   * `max_scheduled_date`  - Latest scheduled date
  #   * `allowed_recipients`  - List of account IDs. The payment recipient must be one of these accounts. No restriction applies if this field is omitted
  # """

  defstruct [
    :max_purpose_length,
    :supported_text_keys,
    :min_scheduled_date,
    :max_scheduled_date,
    allowed_recipients: []
  ]

  @type t :: %__MODULE__{}

end
