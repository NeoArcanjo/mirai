defmodule PollingApp.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PollingApp.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> PollingApp.Polls.create_poll()

    poll
  end
end
