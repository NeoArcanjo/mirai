defmodule PollingAppWeb.UserLoginLiveTest do
  use PollingAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import PollingApp.AccountsFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Log in"
      assert html =~ "Register"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      user = user_fixture(%{username: "test_user"})

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form", user: %{username: user.username, remember_me: true})

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back!"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form", user: %{username: "test", remember_me: true})

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid username"

      assert redirected_to(conn) == "/users/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign up")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")

      assert login_html =~ "Register"
    end
  end
end
