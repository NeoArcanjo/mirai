defmodule PollingApp.DataLayer do
  @moduledoc """
  This module defines the data layer for the application.

  ## Examples

      iex> {:ok, data} = PollingApp.DataLayer.start_link([])
      iex> PollingApp.DataLayer.put(data, :key, "value")
      :ok
      iex> PollingApp.DataLayer.get(data, :key)
      {:ok, "value"}
      iex> PollingApp.DataLayer.list(data)
      ["value"]
      iex> PollingApp.DataLayer.delete(data, :key)
      :ok
      iex> PollingApp.DataLayer.get(data, :key)
      {:error, :not_found}
      iex> PollingApp.DataLayer.put(data, :key, "value")
      :ok
      iex> PollingApp.DataLayer.clear(data)
      :ok
      iex> PollingApp.DataLayer.list(data)
      []
  """

  use Agent

  @spec start_link(keyword()) :: {:error, any()} | {:ok, pid()}
  @doc """
  Starts a new data.
  """
  def start_link(name) do
    name = Keyword.get(name, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @spec get(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: any()
  @doc """
  Gets a value from the `data` by `key`.
  """
  def get(data, key) do
    Agent.get(data, &Map.get(&1, key))
    |> case do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  @spec put(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any(), any()) :: :ok
  @doc """
  Puts the `value` for the given `key` in the `data`.
  """
  def put(data, key, value) do
    Agent.update(data, &Map.put(&1, key, value))
  end

  @spec delete(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: :ok
  @doc """
  Removes the value for the given `key` from the `data`.
  """
  def delete(data, key) do
    Agent.update(data, &Map.delete(&1, key))
  end

  @spec list(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  @doc """
  Lists all entries in the `data`.
  """
  def list(data) do
    Agent.get(data, & &1)
    |> Map.values()
  end

  @doc """
  Clear the `data`.
  """
  def clear(data) do
    Agent.update(data, fn _ -> %{} end)
  end
end
