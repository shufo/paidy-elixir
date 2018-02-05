defmodule Paidy.Token do
  @moduledoc """
  API for working with Token at Paidy. Through this API you can:

  * suspend a token
  * resume a token
  * delete a token
  * get a token
  * get all tokens

  tokens for credit card allowing you to use instead of a credit card number in various operations.

  (API ref https://paidy.com/docs/api/jp/index.html#3-)
  """

  @endpoint "tokens"

  @doc """
  Retrieve a token by its id. Returns 404 if not found.
  ## Example

  ```
  {:ok, token} = Paidy.Token.get "token_id"
  ```
  """
  def get(id) do
    get(id, Paidy.config_or_env_key())
  end

  @doc """
  Retrieve a token by its id using given api key.
  ## Example

  ```
  {:ok, token} = Paidy.Token.get "token_id", key
  ```
  """
  def get(id, key) do
    Paidy.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Paidy.Util.handle_paidy_response()
  end

  @doc """
  Retrieve all tokens..
  ## Example

  ```
  {:ok, tokens} = Paidy.Token.all
  ```
  """
  def all() do
    all Paidy.config_or_env_key()
  end

  @doc """
  Retrieve all tokens using given api key.
  ## Example

  ```
  {:ok, tokens} = Paidy.Token.all, key
  ```
  """
  def all(key) do
    Paidy.make_request_with_key(:get, "#{@endpoint}/", key, %{})
    |> Paidy.Util.handle_paidy_response()
  end

  @doc """
  Suspend a token.
  You can set a suspend reason code from the following.

    - `consumer.requested`
    - `merchant.requested`
    - `fraud.suspected`
    - `general`

  ## Example

  ```
  params = %{
    reason: %{
      code: "fraud.suspected",
      description: "Token suspended because fraud suspected."
    }
  }

  {:ok, token} = Paidy.Token.suspend "token_id", params
  ```
  """
  def suspend(id, params) do
    suspend(id, params, Paidy.config_or_env_key())
  end

  @doc """
  Suspend a token by its id using given api key.
  ## Example

  ```
  params = %{
    reason: %{
      code: "fraud.suspected",
      description: "Token suspended because fraud suspected."
    }
  }

  {:ok, token} = Paidy.Token.suspend "token_id", params, key
  ```
  """
  def suspend(id, params, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/suspend", key, params)
    |> Paidy.Util.handle_paidy_response()
  end

  @doc """
  Resume a token.
  You can set a resume reason code from the following.

    - `consumer.requested`
    - `merchant.requested`
    - `general`

  ## Example

  ```
  params = %{
    reason: %{
      code: "merchant.requested",
      description: "Token is being resumed because the subscription item is back in stock"
    }
  }

  {:ok, token} = Paidy.Token.resume "token_id", params
  ```
  """
  def resume(id, params) do
    resume(id, params, Paidy.config_or_env_key())
  end

  @doc """
  Resume a token by its id using given api key.
  ## Example

  ```
  params = %{
    reason: {
      code: "merchant.requested",
      description: "Token is being resumed because the subscription item is back in stock"
    }
  }

  {:ok, token} = Paidy.Token.resume "token_id", params, key
  ```
  """
  def resume(id, params, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/resume", key, params)
    |> Paidy.Util.handle_paidy_response()
  end

  @doc """
  Delete a token.
  You can set a delete reason code from the following.

    - `consumer.requested`
    - `subscription.expired`
    - `merchant.requested`
    - `fraud.detected`
    - `general`

  ## Example

  ```
  params = %{
    reason: %{
      code: "consumer.requested",
      description: "Token was deleted because consumer canceled the subscription"
    }
  }

  {:ok, token} = Paidy.Token.delete "token_id", params
  ```
  """
  def delete(id, params) do
    delete(id, params, Paidy.config_or_env_key())
  end

  @doc """
  Delete a token by its id using given api key.
  ## Example

  ```
  params = %{
    reason: %{
      code: "consumer.requested",
      description: "Token was deleted because consumer canceled the subscription"
    }
  }

  {:ok, token} = Paidy.Token.delete "token_id", params, key
  ```
  """
  def delete(id, params, key) do
    Paidy.make_request_with_key(:post, "#{@endpoint}/#{id}/delete", key, params)
    |> Paidy.Util.handle_paidy_response()
  end
end
