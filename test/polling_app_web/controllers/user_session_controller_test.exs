defmodule PollingAppWeb.UserSessionControllerTest do
  use PollingAppWeb.ConnCase, async: true

  alias PollingApp.Accounts
  alias PollingAppWeb.Router.Helpers, as: Routes

  setup do
    {:ok, user: %PollingApp.Accounts.User{username: "test_user"}}
  end

  test "creates session for registered user", %{conn: conn, user: user} do
    Accounts.register_user(%{username: user.username})

    conn =
      post(
        conn,
        Routes.user_session_path(conn, :create, %{
          "_action" => "registered",
          "user" => %{"username" => user.username}
        })
      )

    assert get_flash(conn, :info) == "Account created successfully!"
    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "creates session for existing user", %{conn: conn, user: user} do
    Accounts.register_user(%{username: user.username})

    conn =
      post(
        conn,
        Routes.user_session_path(conn, :create, %{"user" => %{"username" => user.username}})
      )

    assert get_flash(conn, :info) == "Welcome back!"
    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "fails to create session for non-existent user", %{conn: conn} do
    conn =
      post(
        conn,
        Routes.user_session_path(conn, :create, %{"user" => %{"username" => "non_existent_user"}})
      )

    assert get_flash(conn, :error) == "Invalid username"
    assert redirected_to(conn) == Routes.user_session_path(conn, :new)
  end

  test "deletes session", %{conn: conn} do
    conn = delete(conn, Routes.user_session_path(conn, :delete))
    assert get_flash(conn, :info) == "Logged out successfully."
    assert redirected_to(conn) == Routes.page_path(conn, :index)
  end
end
