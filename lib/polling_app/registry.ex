defmodule PollingApp.Registry do
  @moduledoc """
  This module defines the middleware for the data layer and the ETS table.
  """

  alias PollingApp.DataLayer
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given options.

  `:name` is always required.
  """
  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up a value in the ETS table.
  """
  def lookup(server, value) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, value) do
      [{^value, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Creates a new entry in the registry.
  """
  def create(server, key, values) do
    GenServer.cast(server, {:create, key, values})
  end

  @doc """
  Updates an existing entry in the registry.
  """
  def update(server, key, values) do
    GenServer.cast(server, {:update, key, values})
  end

  @doc """
  Deletes an entry from the registry.
  """
  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  @doc """
  Lists all entries in the registry.
  """
  def list(server) do
    GenServer.call(server, :list)
  end

  ## Server callbacks

  @impl true
  def init(table) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_cast({:create, key, values}, {keys, refs}) do
    # 5. Read and write to the ETS table instead of the map
    case lookup(keys, key) do
      {:ok, _pid} ->
        {:noreply, {keys, refs}}

      :error ->
        {:ok, pid} =
          DynamicSupervisor.start_child(PollingApp.DataLayerSupervisor, PollingApp.DataLayer)

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, key)

        PollingApp.DataLayer.put(pid, key, values)
        :ets.insert(keys, {key, pid})
        {:noreply, {keys, refs}}
    end
  end

  @impl true
  def handle_cast({:update, name, values}, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        PollingApp.DataLayer.put(pid, name, values)
        {:noreply, {names, refs}}

      :error ->
        # Do nothing
        {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_cast({:delete, key}, {keys, refs}) do
    case lookup(keys, key) do
      {:ok, pid} ->
        DataLayer.remove(pid, key)
        {key, refs} = Map.pop(refs, key)
        :ets.delete(keys, key)
        {:noreply, {keys, refs}}

      :error ->
        {:noreply, {keys, refs}}
    end
  end

  @impl true
  def handle_call(:list, _from, {names, _refs} = state) do
    result =
      :ets.tab2list(names)
      |> Enum.map(fn {key, pid} -> DataLayer.get(pid, key) end)

    {:reply, result, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
