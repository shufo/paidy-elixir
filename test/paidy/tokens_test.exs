defmodule Paidy.TokenTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :token

  @tags disabled: false

  setup_all do
    params = %{
      reason: %{
        code: "merchant.requested",
        description: "Token is being resumed because the subscription item is back in stock"
      }
    }
    on_exit fn ->
      use_cassette "tokens_test/teardown1", match_requests_on: [:query, :request_body] do
        Paidy.Token.resume "tok_WXUFR8AAAAwATjVz", params
      end
    end
    {:ok, token_id: "tok_WXUFR8AAAAwATjVz"}
  end

  test "Get by id works", context do
    use_cassette "tokens_test/get", match_requests_on: [:query, :request_body] do
      case Paidy.Token.get context.token_id do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Get by id w/key works", context do
    use_cassette "tokens_test/get_with_key", match_requests_on: [:query, :request_body] do
      case Paidy.Token.get context.token_id, Paidy.config_or_env_key do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end

  test "Get all works", context do
    use_cassette "tokens_test/all", match_requests_on: [:query, :request_body] do
      case Paidy.Token.all do
        {:ok, res} when length(res) > 0 -> assert true
        {:error, err} -> flunk err
      end
    end
  end

  test "Get all w/key works", context do
    use_cassette "tokens_test/all_with_key", match_requests_on: [:query, :request_body] do
      case Paidy.Token.all Paidy.config_or_env_key do
        {:ok, res} when length(res) > 0 -> assert true
        {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Suspend a token works", context do
    use_cassette "tokens_test/suspend", match_requests_on: [:query, :request_body] do
      params = %{
        reason: %{
          code: "fraud.suspected",
          description: "Token suspended because fraud suspected."
        }
      }
      case Paidy.Token.suspend context.token_id, params do
        {:ok, res} ->
          assert res.id

          params = %{
            reason: %{
              code: "merchant.requested",
              description: "Token is being resumed because the subscription item is back in stock"
            }
          }
          {:ok, resumed} = Paidy.Token.resume context.token_id, params
          assert resumed.id

        {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Suspend a token w/key works", context do
    use_cassette "tokens_test/suspend_with_key", match_requests_on: [:query, :request_body] do
      params = %{
        reason: %{
          code: "fraud.suspected",
          description: "Token suspended because fraud suspected."
        }
      }
      case Paidy.Token.suspend context.token_id, params, Paidy.config_or_env_key do
        {:ok, res} ->
          #Apex.ap res
          assert res.id

          params = %{
            reason: %{
              code: "merchant.requested",
              description: "Token is being resumed because the subscription item is back in stock"
            }
          }
          {:ok, resumed} = Paidy.Token.resume context.token_id, params
          assert resumed.id

        {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Delete a token works", context do
    use_cassette "tokens_test/delete", match_requests_on: [:query, :request_body] do
      params = %{
        reason: %{
          code: "consumer.requested",
          description: "Token was deleted because consumer canceled the subscription"
        }
      }
      case Paidy.Token.delete context.token_id, params do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
        {:error, err} -> flunk err
      end
    end
  end
end
