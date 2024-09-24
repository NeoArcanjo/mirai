defmodule PollingApp.PollsFixtures do
  alias PollingApp.Polls
  alias PollingApp.Polls.{Poll, Option, Vote}

  def poll_fixture(attrs \\ %{}) do
    options = [
      %Option{id: Ecto.UUID.generate(), value: "Option 1", votes: 0},
      %Option{id: Ecto.UUID.generate(), value: "Option 2", votes: 0}
    ]

    votes = [
      %Vote{id: Ecto.UUID.generate(), username: "user1"},
      %Vote{id: Ecto.UUID.generate(), username: "user2"}
    ]

    {:ok, poll} =
      %Poll{
        title: "Sample Poll",
        description: "This is a sample poll",
        created_by: "admin",
        options: options,
        votes: votes
      }
      |> Enum.into(attrs)
      |> Polls.create_poll()

    poll
  end

  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      %Option{
        value: "Sample Option",
        votes: 0
      }
      |> Option.changeset(attrs)
      |> Ecto.Changeset.apply_action(:insert)

    option
  end

  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      %Vote{
        username: "sample_user"
      }
      |> Vote.changeset(attrs)
      |> Ecto.Changeset.apply_action(:insert)

    vote
  end
end
