defmodule PollingApp.Polls do
  @moduledoc """
  The Polls context.
  """

  alias PollingApp.DataLayer
  alias PollingApp.Polls.Poll
  alias PollingApp.Registry

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()


  """
  def list_polls do
    Registry.list(:polls)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Gets a single poll.


  ## Examples

      iex> get_poll(123)

      iex> get_poll(456)

  """
  def get_poll(id) do
    Registry.lookup(:polls, id)
    |> case do
      :error -> nil
      {:ok, pid} -> DataLayer.get(pid, id)
    end
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})

      iex> create_poll(%{field: bad_value})

  """
  def create_poll(attrs \\ %{}) do
    {:ok, poll} =
      %Poll{}
      |> Poll.changeset(attrs)
      |> Ecto.Changeset.apply_action(:insert)

    Registry.create(:polls, poll.id, poll)
    |> case do
      :ok -> {:ok, poll}
      _error -> {:error, poll}
    end
  end

  def vote(%{votes: votes, options: options} = poll, option_id, username) do
    votes = [%{username: username} | votes]

    options =
      Enum.map(options, fn option ->
        if option.id == option_id do
          %{option | votes: option.votes + 1}
        else
          option
        end
      end)

    poll
    |> Poll.vote_changeset(%{votes: structs_to_maps(votes), options: structs_to_maps(options)})
    |> Ecto.Changeset.apply_action(:update)
    |> case do
      {:ok, updated_poll} ->
        Registry.update(:polls, poll.id, updated_poll)
        {:ok, updated_poll}

      _error ->
        {:error, poll}
    end
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})

      iex> update_poll(poll, %{field: bad_value})

  """
  def update_poll(poll, attrs) do
    {:ok, updated_poll} =
      poll
      |> Poll.changeset(attrs)
      |> Ecto.Changeset.apply_action(:update)

    Registry.update(:polls, poll.id, updated_poll)
    |> case do
      :ok -> {:ok, updated_poll}
      _error -> {:error, updated_poll}
    end
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{id: id}) do
    Registry.delete(:polls, id)
    |> case do
      :ok -> {:ok, %Poll{}}
      _error -> {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  defp structs_to_maps(structs), do: Enum.map(structs, &struct_to_map/1)

  defp struct_to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.delete(:__meta__)
  end

  defp struct_to_map(map) when is_map(map), do: map
end
