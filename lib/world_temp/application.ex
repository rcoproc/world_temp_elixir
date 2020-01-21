defmodule WorldTemp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  Simple Weather Tracker

  link: https://blog.appsignal.com/2019/12/12/how-to-use-broadway-in-your-elixir-application.html

  ## Examples:
  
    iex> WorldTemp.TempTracker.get_coldest_city()

    iex> WorldTemp.TempTracker.get_hotest_city()
  """

  use Application

  alias WorldTemp.{CityProducer, TempProcessor, TempTracker}

  def start(_type, _args) do
    children = [
      TempTracker,
      CityProducer,
      TempProcessor
    ]

    opts = [strategy: :one_for_one, name: WorldTemp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
