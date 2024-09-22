defmodule PollingApp.Registry do
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
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, value) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, value) do
      [{^value, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, key, values) do
    GenServer.cast(server, {:create, key, values})
  end

  @doc """
  Delete a value from registry
  """
  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  ## Server callbacks

  @impl true
  def init(table) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  # 4. The previous handle_call callback for lookup was removed

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
  def handle_cast({:delete, name}, {names, refs}) do
    case lookup(names, name) do
      {:ok, _pid} ->
        {name, refs} = Map.pop(refs, name)
        :ets.delete(names, name)
        {:noreply, {names, refs}}

      :error ->
        {:noreply, {names, refs}}
    end
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
