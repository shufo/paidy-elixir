defmodule Paidy.PaidyTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock

  @moduletag :paidy

  test "process_url for paidy" do
    assert Paidy.process_url("payments") == "https://api.paidy.com/payments"
  end

  test "make_request_with_key fails when no key is supplied on environment config" do
    with_mock System, [get_env: fn(_opts) -> nil end] do
      assert_raise Paidy.MissingSecretKeyError, fn ->
        Paidy.config_or_env_key
      end
    end
  end

  test "make_request_with_key fails when no key is supplied on paidy request" do
    use_cassette "paidy_test/invalid_key_request", match_requests_on: [:query, :request_body] do
      res = Paidy.make_request_with_key(
        :get, "tokens/", "")
              |> Paidy.Util.handle_paidy_response
      case res do
          {:ok, body} -> assert body.code == "service.exception"
          {:error, err} -> assert String.contains? err["error"]["message"], "YOUR_SECRET_KEY"
          true -> assert false
      end
    end
  end

  test "make_request_with_key returns authentication failed when invalid key is supplied" do
    use_cassette "paidy_test/valid_key_request", match_requests_on: [:query, :request_body] do
      res = Paidy.make_request_with_key(
        :get,"tokens/", "non_empty_secret_key_string")
          |> Paidy.Util.handle_paidy_response
      case res do
        {:ok, body} -> assert body.code == "authentication.failed"
        {:error, err} -> flunk err["error"]["message"]
      end
    end
  end

end
