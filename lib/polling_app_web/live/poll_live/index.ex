defmodule PollingAppWeb.PollLive.Index do
  use PollingAppWeb, :live_view

  alias PollingApp.Polls
  alias PollingApp.Polls.Poll

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :polls, Polls.list_polls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user

    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:username, current_user.username)
    |> assign(:poll, Polls.get_poll(id))
  end

  defp apply_action(socket, :new, _params) do
    current_user = socket.assigns.current_user

    socket
    |> assign(:page_title, "New Poll")
    |> assign(:username, current_user.username)
    |> assign(:poll, %Poll{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  @impl true
  def handle_info({PollingAppWeb.PollLive.FormComponent, {:saved, poll}}, socket) do
    {:noreply, stream_insert(socket, :polls, poll)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Polls.get_poll(id)
    {:ok, _} = Polls.delete_poll(poll)

    {:noreply, stream_delete(socket, :polls, poll)}
  end

  @impl true
  def handle_event(
        "vote",
        %{"poll_id" => poll_id, "option" => option, "username" => username},
        socket
      ) do
    case Polls.vote(poll_id, option, username) do
      :ok -> {:noreply, assign(socket, :polls, Polls.list_polls())}
      :error -> {:noreply, socket}
    end
  end
end
