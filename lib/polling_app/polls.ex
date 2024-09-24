defmodule PollingApp.Polls do
  @moduledoc """
  The Polls context.
  """

  alias PollingApp.DataLayer
  alias PollingApp.Polls.Poll
  alias PollingApp.Registry, as: DataRegistry

  @doc """
  Returns the list of polls.

  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "foo"})
      iex> #{__MODULE__}.list_polls()
      [poll]

  """
  def list_polls do
    polls_pid()
    |> DataLayer.list()
  end

  @doc """
  Gets a single poll.


  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "value"})
      iex> #{__MODULE__}.get_poll(poll.id)
      poll

      iex> #{__MODULE__}.get_poll("456")
      nil

  """
  def get_poll(id) do
    polls_pid()
    |> DataLayer.get(id)
    |> case do
      {:ok, poll} -> poll
      {:error, _} -> nil
    end
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "value"})
      {:ok, %#{Poll}{id: poll.id, title: "value"}}

      iex> #{__MODULE__}.create_poll(%{title: 123})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    with %Ecto.Changeset{} = poll_changeset <- Poll.changeset(%Poll{}, attrs),
         {:ok, poll} <- Ecto.Changeset.apply_action(poll_changeset, :insert),
         pid when is_pid(pid) <- polls_pid(),
         :ok <- DataLayer.put(pid, poll.id, poll) do
      {:ok, poll}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, error}
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
        polls_pid()
        |> DataLayer.put(poll.id, updated_poll)

        {:ok, updated_poll}

      _error ->
        {:error, poll}
    end
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "value"})
      iex> #{__MODULE__}.update_poll(poll, %{title: "new_value"})
      {:ok, %{poll | title: "new_value"}}

      iex> {:ok, poll} = PollingApp.Polls.create_poll(%{title: "value"})
      iex> #{__MODULE__}.update_poll(poll, %{title: 123})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(poll, attrs) do
    with %Ecto.Changeset{} = poll_changeset <- Poll.changeset(poll, attrs),
         {:ok, updated_poll} <- Ecto.Changeset.apply_action(poll_changeset, :update),
         pid when is_pid(pid) <- polls_pid(),
         :ok <- DataLayer.put(pid, poll.id, updated_poll) do
      {:ok, updated_poll}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "value"})
      iex> #{__MODULE__}.delete_poll(poll)
      {:ok, %#{Poll}{}}

  """
  def delete_poll(%Poll{id: id} = poll) do
    DataLayer.delete(polls_pid(), id)

    {:ok, poll}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "value"})
      iex> #{__MODULE__}.change_poll(poll, %{title: "new_value"})
      %Ecto.Changeset{data: %#{Poll}{}, changes: %{title: "new_value"}, valid?: true}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  @doc """
  Resets the data layer

  ## Examples
      iex> {:ok, poll} = #{__MODULE__}.create_poll(%{title: "foo"})
      iex> #{__MODULE__}.list_polls()
      [poll]

      iex> #{__MODULE__}.reset()
      :ok

      iex> #{__MODULE__}.list_polls()
      []
  """
  def reset() do
    DataLayer.clear(polls_pid())
  end

  defp structs_to_maps(structs), do: Enum.map(structs, &struct_to_map/1)

  defp struct_to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.delete(:__meta__)
  end

  defp struct_to_map(map) when is_map(map), do: map

  defp polls_pid() do
    Registry.lookup(DataRegistry, :polls)
    |> case do
      [{pid, _}] -> pid
      [] -> {:error, :no_started_polls}
    end
  end
end
