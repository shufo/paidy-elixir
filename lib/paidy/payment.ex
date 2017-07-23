defmodule Paidy.Payment do
  @moduledoc """
  Functions for working with payments at Paidy. Through this API you can:

    * create a payment,
    * capture a payment,
    * update a payment,
    * get a payment,
    * refund a payment,
    * partially refund a payment.
    * close a payment.

  Paidy API reference: https://paidy.com/docs/api/jp/index.html#2-
  """

  @endpoint "payments"

  @doc """
  Create a payment.

  Creates a payment with createable information.

  Accepts the following parameters:

    * `params` - a list of params to be created (optional; defaults to `[]`).

  Returns a `{:ok, payment}` tuple.

  ## Examples

      params = %{
        amount: 12500,
        shipping_address: %{
            line1: "AXISビル 10F",
            line2: "六本木4-22-1",
            state: "港区",
            city: "東京都",
            zip: "106-2004"
        },
        order: %{
            order_ref: "your_order_ref",
            items: [%{
                    quantity: 1,
                    id: "PDI001",
                    title: "Paidyスニーカー",
                    description: "Paidyスニーカー",
                    unit_price: 12000
                }],
            tax: 300,
            shipping: 200
        },
        store_name: "Paidy sample store",
        buyer_data: %{
            age: 29,
            order_count: 1000,
            ltv: 250000,
            last_order_amount: 20000,
            last_order_at: 20
        },
        description: "hoge",
        token_id: "tok_foobar",
        currency: "JPY",
        metadata: %{}
      }

      {:ok, payment} = Paidy.Payment.create(params)

  """
  def create(params) do
    create params, Paidy.config_or_env_key
  end

  @doc """
  Create a payment. Accepts Paidy API key.

  Creates a payment with createable information.

  Accepts the following parameters:

    * `params` - a list of params to be created (optional; defaults to `[]`).

  Returns a `{:ok, payment}` tuple.

  ## Examples

      params = %{
        amount: 12500,
        shipping_address: %{
            line1: "AXISビル 10F",
            line2: "六本木4-22-1",
            state: "港区",
            city: "東京都",
            zip: "106-2004"
        },
        order: %{
            order_ref: "your_order_ref",
            items: [%{
                    quantity: 1,
                    id: "PDI001",
                    title: "Paidyスニーカー",
                    description: "Paidyスニーカー",
                    unit_price: 12000
                }],
            tax: 300,
            shipping: 200
        },
        store_name: "Paidy sample store",
        buyer_data: %{
            age: 29,
            order_count: 1000,
            ltv: 250000,
            last_order_amount: 20000,
            last_order_at: 20
        },
        description: "hoge",
        token_id: "tok_foobar",
        currency: "JPY",
        metadata: %{}
      }

      {:ok, payment} = Paidy.Payment.create(params, "my_key")

  """
  def create(params, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}", key, params)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Update a payment.

  Updates a payment with changeable information.

  Accepts the following parameters:

    * `params` - a list of params to be updated (optional; defaults to `[]`).
      Available parameters are: `description`, `metadata`, `receipt_email`,
      `fraud_details` and `shipping`.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      params = %{
        description: "Changed payment"
      }

      {:ok, payment} = Paidy.Payment.change("payment_id", params)

  """
  def change(id, params) do
    change id, params, Paidy.config_or_env_key
  end

  @doc """
  Update a payment. Accepts Paidy API key.

  Updates a payment with changeable information.

  Accepts the following parameters:

    * `params` - a list of params to be updated (optional; defaults to `[]`).
      Available parameters are: `description`, `metadata`, `receipt_email`,
      `fraud_details` and `shipping`.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      params = %{
        description: "Changed payment"
      }

      {:ok, payment} = Paidy.Payment.change("payment_id", params, "my_key")

  """
  def change(id, params, key) do
    Paidy.make_request_with_key(:put, "#{@endpoint}/#{id}", key, params)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Capture a payment.

  Captures a payment that is currently pending.

  Note: you can default a payment to be automatically captured by setting `capture: true` in the payment create params.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.capture("payment_id")

  """
  def capture(id) do
    capture id, Paidy.config_or_env_key
  end

  @doc """
  Capture a payment. Accepts Paidy API key.

  Captures a payment that is currently pending.

  Note: you can default a payment to be automatically captured by setting `capture: true` in the payment create params.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.capture("payment_id", "my_key")

  """
  def capture(id, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/captures", key)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Get a payment.

  Gets a payment.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.get("payment_id")

  """
  def get(id) do
    get id, Paidy.config_or_env_key
  end

  @doc """
  Get a payment. Accepts Paidy API key.

  Gets a payment.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.get("payment_id", "my_key")

  """
  def get(id, key) do
    Paidy.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Refund a payment.

  Refunds a payment completely.

  Note: use `refund_partial` if you just want to perform a partial refund.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.refund("payment_id", "capture_id")

  """
  def refund(id, capture_id) do
    refund id, capture_id, Paidy.config_or_env_key
  end

  @doc """
  Refund a payment. Accepts Paidy API key.

  Refunds a payment completely.

  Note: use `refund_partial` if you just want to perform a partial refund.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.refund("payment_id", "capture_id", "my_key")

  """
  def refund(id, capture_id, key) do
    params = %{capture_id: capture_id}
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/refunds", key, params)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Partially refund a payment.

  Refunds a payment partially.

  Accepts the following parameters:

    * `amount` - amount to be refunded (required).

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.refund_partial("payment_id", "capture_id", 500)

  """
  def refund_partial(id, capture_id, amount) do
    refund_partial id, capture_id, amount, Paidy.config_or_env_key
  end

  @doc """
  Partially refund a payment. Accepts Paidy API key.

  Refunds a payment partially.

  Accepts the following parameters:

    * `amount` - amount to be refunded (required).

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.refund_partial("payment_id", "capture_id", 500, "my_key")

  """
  def refund_partial(id, capture_id, amount, key) do
    params = %{capture_id: capture_id, amount: amount}
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/refunds", key, params)
    |> Paidy.Util.handle_paidy_response
  end

  @doc """
  Close a payment.

  Closes a payment that is currently pending.

  Note: you can default a payment to be automatically closed by setting `close: true` in the payment create params.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.close("payment_id")

  """
  def close(id) do
    close id, Paidy.config_or_env_key
  end

  @doc """
  Close a payment. Accepts Paidy API key.

  Closes a payment that is currently pending.

  Note: you can default a payment to be automatically closed by setting `close: true` in the payment create params.

  Returns a `{:ok, payment}` tuple.

  ## Examples

      {:ok, payment} = Paidy.Payment.close("payment_id", "my_key")

  """
  def close(id, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/close", key)
    |> Paidy.Util.handle_paidy_response
  end
end
