defmodule PollingAppWeb.UserSessionControllerTest do
  use PollingAppWeb.ConnCase, async: true

  alias PollingApp.Accounts

  setup do
    {:ok, user: %PollingApp.Accounts.User{username: "test_user"}}
  end

  test "creates session for registered user", %{conn: conn, user: user} do
    Accounts.register_user(%{username: user.username})

    conn =
      post(
        conn,
        ~p"/users/log_in",
        %{
          "_action" => "registered",
          "user" => %{"username" => user.username}
        }
      )

    assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Account created successfully!"
    assert redirected_to(conn) == "/"
  end

  test "creates session for existing user", %{conn: conn, user: user} do
    Accounts.register_user(%{username: user.username})

    conn =
      post(
        conn,
        ~p"/users/log_in",
        %{"user" => %{"username" => user.username}}
      )

    assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back!"
    assert conn.status == 302
    assert redirected_to(conn) == "/"
  end

  test "fails to create session for non-existent user", %{conn: conn} do
    conn =
      post(
        conn,
        ~p"/users/log_in",
        %{"user" => %{"username" => "non_existent_user"}}
      )

    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid username"
    assert redirected_to(conn) == "/users/log_in"
  end

  test "deletes session", %{conn: conn} do
    conn = delete(conn, ~p"/users/log_out")
    assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Logged out successfully."
    assert redirected_to(conn) == "/users/log_in"
  end
end
