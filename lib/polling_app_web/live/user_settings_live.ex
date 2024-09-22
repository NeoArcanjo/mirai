defmodule PollingAppWeb.UserSettingsLive do
  use PollingAppWeb, :live_view

  alias PollingApp.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account username</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <.simple_form
          for={@username_form}
          id="username_form"
          phx-submit="update_username"
          phx-change="validate_username"
        >
          <.input field={@username_form[:username]} type="text" label="username" required />
          <:actions>
            <.button phx-disable-with="Changing...">Change username</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_username(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "username changed successfully.")

        :error ->
          put_flash(socket, :error, "username change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    username_changeset = Accounts.change_user_username(user)

    socket =
      socket
      |> assign(:current_username, user.username)
      |> assign(:username_form, to_form(username_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_username", params, socket) do
    %{"user" => user_params} = params

    username_form =
      socket.assigns.current_user
      |> Accounts.change_user_username(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, username_form: username_form)}
  end

  def handle_event("update_username", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_username(user, user_params) do
      {:ok, applied_user} ->
        applied_user |> IO.inspect(label: "lib/polling_app_web/live/user_settings_live.ex:75")
        info = "Username updated successfully"
        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :username_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
