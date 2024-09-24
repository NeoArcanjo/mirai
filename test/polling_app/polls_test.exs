defmodule PollingApp.PollsTest do
  use ExUnit.Case, async: true
  alias PollingApp.Polls
  alias PollingApp.Polls.Poll

  setup do
    on_exit(fn -> Polls.reset() end)
  end

  describe "list_polls/0" do
    test "returns the list of polls" do
      attrs = %{id: 1, title: "Poll 1"}
      attrs2 = %{id: 2, title: "Poll 2"}
      {:ok, poll1} = Polls.create_poll(attrs)
      {:ok, poll2} = Polls.create_poll(attrs2)

      assert polls = Polls.list_polls()
      assert Enum.count(polls) == 2
      assert poll1 in polls
      assert poll2 in polls
    end
  end

  describe "get_poll/1" do
    test "returns the poll when it exists" do
      attrs = %{title: "Poll 1", options: [%{value: "Option 1", votes: 0}]}
      {:ok, %{id: uuid} = poll} = Polls.create_poll(attrs)

      assert Polls.get_poll(uuid) == poll
    end

    test "returns nil when the poll does not exist" do
      assert Polls.get_poll(456) == nil
    end
  end

  describe "create_poll/1" do
    test "creates a poll with valid attributes" do
      attrs = %{title: "New Poll"}
      assert {:ok, %Poll{} = poll} = Polls.create_poll(attrs)
      assert poll.title == "New Poll"
    end

    test "returns error with invalid attributes" do
      attrs = %{invalid: "attribute"}
      assert {:error, _} = Polls.create_poll(attrs)
    end
  end

  describe "vote/3" do
    test "adds a vote to the poll option" do
      attrs = %{
        options: [%{votes: 0, value: "Option 1"}, %{votes: 0, value: "Option 2"}],
        votes: [],
        title: "Poll"
      }

      {:ok, %{options: [first_option | _others]} = poll} = Polls.create_poll(attrs)

      {:ok, updated_poll} = Polls.vote(poll, first_option.id, "user1")
      assert Enum.any?(updated_poll.votes, fn vote -> vote.username == "user1" end)
      assert Enum.find(updated_poll.options, fn opt -> opt.id == first_option.id end).votes == 1
    end
  end

  describe "update_poll/2" do
    test "updates the poll with valid attributes" do
      attrs = %{id: 1, title: "Old Title"}
      {:ok, poll} = Polls.create_poll(attrs)

      {:ok, updated_poll} = Polls.update_poll(poll, %{title: "New Title"})
      assert updated_poll.title == "New Title"
    end
  end

  describe "delete_poll/1" do
    test "deletes the poll" do
      attrs = %{id: 1, title: "Poll to Delete"}
      {:ok, poll} = Polls.create_poll(attrs)

      assert {:ok, %Poll{}} = Polls.delete_poll(poll)
      assert Polls.get_poll(poll.id) == nil
    end
  end

  describe "change_poll/2" do
    test "returns a changeset for tracking poll changes" do
      attrs = %Poll{id: 1, title: "Poll"}
      changeset = Polls.change_poll(attrs, %{title: "Updated Poll"})
      assert changeset.valid?
      assert changeset.changes.title == "Updated Poll"
    end
  end
end
