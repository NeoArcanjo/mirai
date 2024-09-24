defmodule PollingApp.DataLayerTest do
  use ExUnit.Case

  alias PollingApp.DataLayer
  doctest PollingApp.DataLayer

  setup do
    {:ok, data} = DataLayer.start_link(name: {:via, Registry, {PollingApp.Registry, :data}})
    %{data: data}
  end

  test "starts with an empty map", %{data: data} do
    assert Agent.get(data, & &1) == %{}
  end

  test "gets a value by key", %{data: data} do
    DataLayer.put(data, :key, "value")
    assert DataLayer.get(data, :key) == {:ok, "value"}
  end

  test "puts a value for a given key", %{data: data} do
    DataLayer.put(data, :key, "value")
    assert Agent.get(data, &Map.get(&1, :key)) == "value"
  end

  test "removes a value by key", %{data: data} do
    DataLayer.put(data, :key, "value")
    DataLayer.delete(data, :key)
    assert DataLayer.get(data, :key) == {:error, :not_found}
  end
end
