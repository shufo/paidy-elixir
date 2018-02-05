defmodule Paidy do
  @moduledoc """
    A HTTP client for Paidy.
    This module contains the Application that you can use to perform
    transactions on paidy API.
    ### Configuring
    By default the PAIDY_SECRET_KEY environment variable is used to find
    your API key for Paidy. You can also manually set your API key by
    configuring the :paidy application. You can see the default
    configuration in the default_config/0 private function at the bottom of
    this file. The value for platform client id is optional.

      config :paidy, secret_key: YOUR_PAIDY_KEY
      config :paidy, platform_client_id: PAIDY_PLATFORM_CLIENT_ID
  """

  # Let's build on top of HTTPoison
  use HTTPoison.Base
  use Retry

  @default_httpoison_options [
    timeout: 30000,
    recv_timeout: 80000
  ]

  defmodule MissingSecretKeyError do
    defexception message: """
                   The secret_key setting is required so that we can report the
                   correct environment instance to Paidy. Please configure
                   secret_key in your config.exs and environment specific config files
                   to have accurate reporting of errors.
                   config :paidy, secret_key: YOUR_SECRET_KEY
                 """
  end

  @doc """
  Grabs PAIDY_SECRET_KEY from system ENV
  Returns binary
  """
  def config_or_env_key do
    require_paidy_key()
  end

  @doc """
  Grabs PAIDY_PLATFORM_CLIENT_ID from system ENV
  Returns binary
  """
  def config_or_env_platform_client_id do
    Application.get_env(:paidy, :platform_client_id) || System.get_env("PAIDY_PLATFORM_CLIENT_ID")
  end

  @doc """
  Creates the URL for our endpoint.
  Args:
    * endpoint - part of the API we're hitting
  Returns string
  """
  def process_url(endpoint) do
    "https://api.paidy.com/" <> endpoint
  end

  @doc """
  Set our request headers for every request.
  """
  def req_headers(key) do
    Map.new()
    |> Map.put("Authorization", "Bearer #{key}")
    |> Map.put("User-Agent", "Paidy/2016-07-01 paidy/0.1.0")
    |> Map.put("Content-Type", "application/json")
    |> Map.put("Paidy-Version", "2016-07-01")
    |> Map.put("Locale", Application.get_env(:paidy, :locale, "en"))
  end

  @doc """
  Converts the binary keys in our response to atoms.
  Args:
    * body - string binary response
  Returns Record or ArgumentError
  """
  def process_response_body(body) do
    Poison.decode!(body)
  end

  @doc """
  Boilerplate code to make requests with a given key.
  Args:
    * method - request method
    * endpoint - string requested API endpoint
    * key - paidy key passed to the api
    * body - request body
    * headers - request headers
    * options - request options
  Returns tuple
  """
  def make_request_with_key(method, endpoint, key, body \\ %{}, headers \\ %{}, options \\ [])

  def make_request_with_key(method, endpoint, key, body, headers, options)
      when method in [:put, :post] do
    rb = body |> Poison.encode!()

    rh =
      req_headers(key)
      |> Map.merge(headers)
      |> Map.to_list()

    options = Keyword.merge(httpoison_request_options(), options)

    {:ok, response} =
      retry with: exp_backoff |> randomize |> expiry(60_000) do
        request(method, endpoint, rb, rh, options)
      end

    response.body
  end

  def make_request_with_key(method, endpoint, key, body, headers, options) do
    rb = Paidy.URI.encode_query(body)

    rh =
      req_headers(key)
      |> Map.merge(headers)
      |> Map.to_list()

    options = Keyword.merge(httpoison_request_options(), options)

    {:ok, response} =
      retry with: exp_backoff |> randomize |> expiry(60_000) do
        request(method, endpoint, rb, rh, options)
      end

    response.body
  end

  @doc """
  Boilerplate code to make requests with the key read from config or env.see config_or_env_key/0
  Args:
  * method - request method
  * endpoint - string requested API endpoint
  * key - paidy key passed to the api
  * body - request body
  * headers - request headers
  * options - request options
  Returns tuple
  """
  def make_request(method, endpoint, body \\ %{}, headers \\ %{}, options \\ []) do
    make_request_with_key(method, endpoint, config_or_env_key(), body, headers, options)
  end

  @doc """
  """
  def make_oauth_token_callback_request(body) do
    rb = Paidy.URI.encode_query(body)

    rh =
      req_headers(Paidy.config_or_env_key())
      |> Map.to_list()

    options = httpoison_request_options()
    HTTPoison.request(:post, "#{Paidy.Connect.base_url()}oauth/token", rb, rh, options)
  end

  @doc """
  """
  def make_oauth_deauthorize_request(paidy_user_id) do
    rb =
      Paidy.URI.encode_query(
        paidy_user_id: paidy_user_id,
        client_id: Paidy.config_or_env_platform_client_id()
      )

    rh =
      req_headers(Paidy.config_or_env_key())
      |> Map.to_list()

    options = httpoison_request_options()
    HTTPoison.request(:post, "#{Paidy.Connect.base_url()}oauth/deauthorize", rb, rh, options)
  end

  defp require_paidy_key do
    case Application.get_env(:paidy, :secret_key, System.get_env("PAIDY_SECRET_KEY")) ||
           :not_found do
      :not_found ->
        raise MissingSecretKeyError

      value ->
        value
    end
  end

  defp httpoison_request_options() do
    @default_httpoison_options
    |> Keyword.merge(Application.get_env(:paidy, :httpoison_options, []))
  end
end
