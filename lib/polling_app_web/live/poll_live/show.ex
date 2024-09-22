defmodule PollingAppWeb.PollLive.Show do
  use PollingAppWeb, :live_view

  alias PollingApp.Polls

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    case Polls.get_poll(id) do
      nil ->
        # Redirect to home if poll is not found
        socket = push_navigate(socket, to: ~p"/")
        {:noreply, socket}

      poll ->
        current_user = socket.assigns.current_user

        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:username, current_user.username)
         |> assign(:poll, poll)}
    end
  end

  defp page_title(:show), do: "Show Poll"
  defp page_title(:edit), do: "Edit Poll"
end
