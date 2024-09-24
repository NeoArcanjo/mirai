defmodule PollingAppWeb.UserRegistrationLiveTest do
  use PollingAppWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias PollingApp.Accounts

  setup do
    {:ok, user: %PollingApp.Accounts.User{}}
  end

  test "renders registration form", %{conn: conn} do
    {:ok, _view, html} = live(conn, "~/users/register")
    assert html =~ "Register for an account"
    assert html =~ "Username"
    assert html =~ "Create an account"
  end

  test "validates user input", %{conn: conn} do
    {:ok, view, _html} = live(conn, "~/users/register")

    view
    |> form("#registration_form", user: %{username: ""})
    |> render_change()

    assert render(view) =~ "Oops, something went wrong! Please check the errors below."
  end

  test "registers user successfully", %{conn: conn} do
    {:ok, view, _html} = live(conn, "~/users/register")

    user_params = %{username: "valid_username"}
    Accounts.register_user(user_params)

    view
    |> form("#registration_form", user: user_params)
    |> render_submit()

    assert render(view) =~ "Log in to your account now."
  end

  test "handles registration errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, "~/users/register")

    user_params = %{username: ""}
    Accounts.register_user(user_params)

    view
    |> form("#registration_form", user: user_params)
    |> render_submit()
    |> IO.inspect(label: "test/polling_app_web/live/user_registration_live_test.exs:50")

    assert render(view) =~ "Oops, something went wrong! Please check the errors below."
  end
end
