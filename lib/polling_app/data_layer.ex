defmodule PollingApp.DataLayer do
  @moduledoc """
  This module defines the data layer for the application.
  """

  use Agent

  @doc """
  Starts a new data.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `data` by `key`.
  """
  def get(data, key) do
    Agent.get(data, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `data`.
  """
  def put(data, key, value) do
    Agent.update(data, &Map.put(&1, key, value))
  end

  def remove(data, key) do
    Agent.update(data, &Map.delete(&1, key))
  end
end
