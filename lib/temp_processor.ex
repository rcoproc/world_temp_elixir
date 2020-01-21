defmodule WorldTemp.TempProcessor do
  use Broadway

  alias Broadway.Message

  @moduledoc """
  A Broadway consumer.
  """

  @doc """
  The start_link/1 function defines the various options required 
  by Broadway to orchestrate the data pipeline. 
  You’ll notice that the GenStage producer that we previously 
  created is referenced in the producer keyword list section and we also defined a rate limiter to ensure that we don’t go over our free tier usage on OpenWeatherMap
  """
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {WorldTemp.CityProducer, []},
        transformer: {__MODULE__, :transform, []},
        rate_limiting: [
          allowed_messages: 60,
          interval: 60_000
        ]
      ],
      processors: [
        default: [concurrency: 10]
      ]
    )
  end

  @impl true
  def handle_message(:default, message, _context) do
    message
    |> Message.update_data(fn {city, country} ->
      city_data = {city, country, WorldTemp.TempFetcher.fetch_data(city, country)}

      WorldTemp.TempTracker.update_coldest_city(city_data)

      WorldTemp.TempTracker.update_hotest_city(city_data)
    end)
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, _successful, _failed) do
    :ok
  end
end

