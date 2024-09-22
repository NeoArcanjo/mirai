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
    :ets.tab2list(:polls)
    |> IO.inspect(label: "lib/polling_app/polls.ex:21")
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
      {:ok, pid} -> DataLayer.get(pid, id)   |> IO.inspect(label: "lib/polling_app/polls.ex:38")
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
      _ -> {:error, poll}
    end
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})

      iex> update_poll(poll, %{field: bad_value})

  """
  def update_poll(title, option) do
    :ets.update_element(:polls, title, {3, Map.update(%{}, option, 1, &(&1 + 1))})
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{title: title} = poll) do
    IO.inspect(poll)
    Registry.delete(:polls, title)
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
end
