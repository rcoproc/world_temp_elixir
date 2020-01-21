defmodule WorldTemp.TempTracker do
  use Agent

  @moduledoc """
  Este módulo é um módulo baseado em agente relativamente simples 
  que nos permite recuperar a cidade mais fria atual 
  ou atualizá-la se o valor fornecido for menor que o valor definido atualmente
  """

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  @doc """
  Get the coldest city

  ## Example
    iex> WorldTemp.TempTracker.get_coldest_city()
  """
  def get_coldest_city do
    Agent.get(__MODULE__, fn {city, country, temp} ->
      "The coldest city on earth is currently #{city}, #{country} with a temperature of #{
        kelvin_to_c(temp)
      }°C"
    end)
  end

  def update_coldest_city(:error), do: nil

  def update_coldest_city({_, _, new_temp} = new_data) do
    Agent.update(__MODULE__, fn
      {_, _, orig_temp} = orig_data ->
        if new_temp < orig_temp, do: new_data, else: orig_data

      nil ->
        new_data
    end)
  end

  @doc """
  Get the hotest city

  ## Example
  iex> WorldTemp.TempTracker.get_hotest_city()
  """
  def get_hotest_city do
    Agent.get(__MODULE__, fn {city, country, temp} ->
      "The hotest city on earth is currently #{city}, #{country} with a temperature of #{
        kelvin_to_c(temp)
      }°C"
    end)
  end

  def update_hotest_city(:error), do: nil

  def update_hotest_city({_, _, new_temp} = new_data) do
    Agent.update(__MODULE__, fn
      {_, _, orig_temp} = orig_data ->
        if new_temp > orig_temp, do: new_data, else: orig_data

      nil ->
        new_data
    end)
  end

  defp kelvin_to_c(kelvin), do: kelvin - 273.15
end

