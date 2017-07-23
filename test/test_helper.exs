ExUnit.start
#Paidy.start
ExUnit.configure [exclude: [disabled: true], seed: 0 ]
ExVCR.Config.filter_sensitive_data("sk_test_.*", "PAIDY_SECRET_KEY_PLACEHOLDER")
ExVCR.Config.filter_sensitive_data(~s("tok_.*?"), ~s("TOKEN_PLACEHOLDER"))
ExVCR.Config.filter_sensitive_data(~s("mer_.*?"), ~s("MERCHANT_PLACEHOLDER"))
ExVCR.Config.filter_sensitive_data(~s(/tok_.*?/), ~s(/TOKEN_PLACEHOLDER/))
ExVCR.Config.filter_sensitive_data(~s(/tok_[0-9a-zA-Z]{1,16}$), ~s(/TOKEN_PLACEHOLDER))
ExVCR.Config.filter_request_headers("Authorization")
ExVCR.Config.filter_url_params(true)

defmodule Helper do
  def create_payment(params) do
    {:ok, payment} = Paidy.Payment.create params
    payment
  end
end
