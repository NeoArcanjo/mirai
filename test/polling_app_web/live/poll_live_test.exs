defmodule PollingAppWeb.PollLiveTest do
  use PollingAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import PollingApp.PollsFixtures

  @create_attrs %{
    title: "some title",
    options: %{"0" => %{"_persistent_id" => "0", "value" => "Some option"}}
  }
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_poll(_) do
    poll = poll_fixture(created_by: "some_username")
    %{poll: poll}
  end

  describe "Index" do
    setup [:create_poll, :register_and_log_in_user]

    test "lists all polls", %{conn: conn, poll: poll} do
      {:ok, _index_live, html} = live(conn, ~p"/polls")

      assert html =~ "Listing Polls"
      assert html =~ poll.title
    end

    test "saves new poll", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/polls")

      assert index_live |> element("a", "New Poll") |> render_click() =~ "New Poll"
      assert page_title(index_live) =~ "New Poll"

      assert_patch(index_live, ~p"/polls/new")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/polls")

      html = render(index_live)

      assert html =~ "Success"
      assert html =~ "New poll available"
      assert html =~ "some title"
      assert html =~ "some_username"
    end

    test "deletes poll in listing", %{conn: conn, poll: poll} do
      {:ok, index_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      assert index_live |> element("a", "Delete poll") |> render_click()
      flash = assert_redirect(index_live, ~p"/polls")

      assert flash["info"] == "Poll has been deleted"
    end
  end

  describe "Show" do
    setup [:create_poll, :register_and_log_in_user]

    test "displays poll", %{conn: conn, poll: poll} do
      {:ok, _show_live, html} = live(conn, ~p"/polls/#{poll}")

      assert html =~ "Show Poll"
      assert html =~ poll.title
    end

    test "updates poll within modal", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll}")

      assert show_live |> element("a", "Edit poll") |> render_click() =~
               "Edit Poll"

      assert_patch(show_live, ~p"/polls/#{poll}/show/edit")

      assert show_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/polls/#{poll}")

      html = render(show_live)

      assert html =~ "Success"
      assert html =~ "Options has been updated"
      assert html =~ "some updated title"
    end

    test "voting in modal", %{conn: conn, poll: %{options: [option | _]} = poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll}")

      assert show_live |> element("#poll-vote-form-#{option.id}") |> render_submit() =~ "1 votes"

      html = render(show_live)
      assert html =~ "Success"
      assert html =~ "Vote added successfully"

      assert show_live |> form("#poll-vote-form-#{option.id}") |> render_submit() =~
      "1 votes"

      html = render(show_live)
      assert html =~ "Error!"
      assert html =~ "Already voted"

    end
  end

  describe "Not authenticated" do
    setup [:create_poll]

    test "redirects if not authenticated", %{conn: conn, poll: poll} do
      {:error, {:redirect, %{flash: _flash, to: "/users/log_in"}}} =
        live(conn, ~p"/polls/#{poll}")
    end
  end
end
