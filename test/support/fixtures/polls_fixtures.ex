defmodule PollingApp.PollsFixtures do
  @moduledoc false
  alias PollingApp.Polls

  def poll_fixture(attrs \\ %{}) do
    options = [
      option_fixture(%{value: "Option 1"}),
      option_fixture(%{value: "Option 2"})
    ]

    votes = [
      vote_fixture(%{username: "user1"}),
      vote_fixture(%{username: "user2"})
    ]

    {:ok, poll} =
      attrs
      |> Enum.into(%{
        title: "Sample Poll",
        description: "This is a sample poll",
        created_by: "admin",
        options: options,
        votes: votes
      })
      |> Polls.create_poll()

    poll
  end

  def option_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      value: "Sample Option",
      votes: 0
    })
  end

  def vote_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: "sample_user"
    })
  end
end
