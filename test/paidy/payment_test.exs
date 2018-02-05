defmodule Paidy.PaymentTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :payment

  setup_all do
    {:ok, %{}}
  end

  setup do
    use_cassette "payment_test/setup", match_requests_on: [:query, :request_body] do
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
          items: [
            %{
              quantity: 1,
              id: "PDI001",
              title: "Paidyスニーカー",
              description: "Paidyスニーカー",
              unit_price: 12000
            }
          ],
          tax: 300,
          shipping: 200
        },
        store_name: "Paidy sample store",
        buyer_data: %{
          age: 29,
          order_count: 1000,
          ltv: 250_000,
          last_order_amount: 20000,
          last_order_at: 20
        },
        description: "hoge",
        token_id: "tok_WXUMS8AAAA4ATjV0",
        currency: "JPY",
        metadata: %{}
      }

      payment = Helper.create_payment(params)

      on_exit(fn ->
        use_cassette "payment_test/teardown1", match_requests_on: [:query, :request_body] do
          {:ok, _} = Paidy.Payment.close(payment.id)
        end
      end)

      {:ok, payment: payment, params: params}
    end
  end

  test "Get a payment works", %{payment: payment} do
    use_cassette "payment_test/get", match_requests_on: [:query, :request_body] do
      case Paidy.Payment.get(payment.id) do
        {:ok, res} -> assert res.id
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Get w/key works", %{payment: payment} do
    use_cassette "payment_test/get_with_key", match_requests_on: [:query, :request_body] do
      case Paidy.Payment.get(payment.id, Paidy.config_or_env_key()) do
        {:ok, payment} -> assert payment.id
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Capture works", %{params: params} do
    use_cassette "payment_test/capture", match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(params)

      case Paidy.Payment.capture(payment.id) do
        {:ok, captured} -> assert captured.captures |> Enum.count() == 1
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Capture w/key works", %{params: params} do
    use_cassette "payment_test/capture_with_key", match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(params)

      case Paidy.Payment.capture(payment.id, Paidy.config_or_env_key()) do
        {:ok, captured} -> assert captured.captures |> Enum.count() == 1
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Change(Update) works", context do
    use_cassette "payment_test/change", match_requests_on: [:query, :request_body] do
      params = %{description: "Changed payment"}

      case Paidy.Payment.change(context.payment.id, params) do
        {:ok, changed} -> assert changed.description == "Changed payment"
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Change(Update) w/key works", %{payment: payment} do
    use_cassette "payment_test/change_with_key", match_requests_on: [:query, :request_body] do
      params = %{description: "Changed payment"}

      case Paidy.Payment.change(payment.id, params, Paidy.config_or_env_key()) do
        {:ok, changed} -> assert changed.description == "Changed payment"
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Refund works", context do
    use_cassette "payment_test/refund", match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(context.params)
      {:ok, captured} = Paidy.Payment.capture(payment.id)
      capture_id = captured.captures |> List.first() |> Map.get("id")

      case Paidy.Payment.refund(payment.id, capture_id) do
        {:ok, refunded} -> assert refunded.refunds |> List.first() |> Map.get("amount") == 12500
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Refund w/key works", context do
    use_cassette "payment_test/refund_with_key", match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(context.params)
      {:ok, captured} = Paidy.Payment.capture(payment.id)
      capture_id = captured.captures |> List.first() |> Map.get("id")

      case Paidy.Payment.refund(payment.id, capture_id, Paidy.config_or_env_key()) do
        {:ok, refunded} -> assert refunded.refunds |> List.first() |> Map.get("amount") == 12500
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Refund partial works", context do
    use_cassette "payment_test/partial_refund", match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(context.params)
      {:ok, captured} = Paidy.Payment.capture(payment.id)
      capture_id = captured.captures |> List.first() |> Map.get("id")

      case Paidy.Payment.refund_partial(payment.id, capture_id, 500) do
        {:ok, refunded} -> assert refunded.refunds |> List.first() |> Map.get("amount") == 500
        {:error, err} -> flunk(inspect(err))
      end
    end
  end

  test "Refund partial w/key works", context do
    use_cassette "payment_test/partial_refund_with_key",
      match_requests_on: [:query, :request_body] do
      payment = Helper.create_payment(context.params)
      {:ok, captured} = Paidy.Payment.capture(payment.id)
      capture_id = captured.captures |> List.first() |> Map.get("id")

      case Paidy.Payment.refund_partial(payment.id, capture_id, 500, Paidy.config_or_env_key()) do
        {:ok, refunded} -> assert refunded.refunds |> List.first() |> Map.get("amount") == 500
        {:error, err} -> flunk(inspect(err))
      end
    end
  end
end
