# Paidy

Paidy client for Elixir

## Features

### Payments
* create a payment
* retrieve a payment
* update a payment
* capture a payment
* refund/partially refund a payment
* close a payment

### Tokens
* retrieve a token
* retrieve all tokens
* suspend a token
* resume a token
* delete a token


## Installation


```elixir
def deps do
  [{:paidy, "~> 0.1.0"}]
end
```

## Usage

### Create a payment

```elixir
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
```

### Retrieve a payment

```elixir
{:ok, payment} = Paidy.Payment.get("payment_id")
```

### Update a payment

```elixir
params = %{
  description: "Changed payment"
}

{:ok, payment} = Paidy.Payment.change("payment_id", params)
```

### Capture a payment

```elixir
{:ok, captured} = Paidy.Payment.capture("payment_id")
```

### Refund a payment

```elixir
{:ok, payment} = Paidy.Payment.capture("payment_id")
capture_id = payment.captures |> List.first |> Map.get("id")

{:ok, payment} = Paidy.Payment.refund("payment_id", capture_id)
```

### Partially refund a payment

```elixir
{:ok, payment} = Paidy.Payment.capture("payment_id")
capture_id = payment.captures |> List.first |> Map.get("id")

{:ok, payment} = Paidy.Payment.refund("payment_id", capture_id, 500)
```

### Close a payment

```elixir
{:ok, payment} = Paidy.Payment.close("payment_id")
```

### Retrieve a token

```elixir
{:ok, token} = Paidy.Token.get "token_id"
```

### Retrieve all tokens

```elixir
{:ok, tokens} = Paidy.Token.all
```

### Suspend a token

```elixir
params = %{
  reason: %{
    code: "fraud.suspected",
    description: "Token suspended because fraud suspected."
  }
}

{:ok, token} = Paidy.Token.suspend "token_id", params
```

### Resume a token

```elixir
params = %{
  reason: %{
    code: "merchant.requested",
    description: "Token is being resumed because the subscription item is back in stock"
  }
}

{:ok, token} = Paidy.Token.resume "token_id", params
```

### Delete a token

```elixir
{:ok, token} = Paidy.Token.delete "token_id", params
```