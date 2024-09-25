defmodule PollingApp.AccountsTest do
  use ExUnit.Case, async: true
  alias PollingApp.Accounts
  alias PollingApp.Accounts.User

  describe "get_user_by_username/1" do
    test "returns the user when the user exists" do
      username = "foo_bar"
      attrs = %{username: username}
      {:ok, user} = Accounts.register_user(attrs)

      assert Accounts.get_user_by_username(username) == user
    end

    test "returns nil when the user does not exist" do
      assert Accounts.get_user_by_username("unknown") == nil
    end
  end

  describe "register_user/1" do
    test "registers a user with valid attributes" do
      attrs = %{username: "new_user"}
      assert {:ok, %User{} = user} = Accounts.register_user(attrs)
      assert user.username == "new_user"
    end

    test "returns error with invalid attributes" do
      attrs = %{username: "1"}

      assert {:error, changeset_error} = Accounts.register_user(attrs)

      assert changeset_error.errors == [
               {
                 :username,
                 {
                   "Must start with a letter.\nUse only letters, numbers and _",
                   [validation: :format]
                 }
               },
               {:username,
                {"should be at least %{count} character(s)",
                 [count: 5, validation: :length, kind: :min, type: :string]}}
             ]
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset for tracking user changes" do
      user = %User{username: "existing_user"}
      changeset = Accounts.change_user_registration(user, %{username: "updated_user"})
      assert changeset.valid?
      assert changeset.changes.username == "updated_user"
    end
  end

  describe "generate_user_session_token/1" do
    test "generates a session token for the user" do
      user = %User{username: "session_user"}
      token = Accounts.generate_user_session_token(user)
      assert is_binary(token)
    end
  end

  describe "get_user_by_session_token/1" do
    test "returns the user with a valid token" do
      attrs = %{username: "token_user"}
      {:ok, user} = Accounts.register_user(attrs)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.get_user_by_session_token(token) == user
    end

    test "returns nil with an invalid token" do
      assert Accounts.get_user_by_session_token("invalid_token") == nil
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the session token" do
      user = %User{username: "delete_token_user"}
      token = Accounts.generate_user_session_token(user)
      Accounts.delete_user_session_token(token)
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end
end
