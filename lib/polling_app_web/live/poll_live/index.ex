defmodule PollingAppWeb.PollLive.Index do
  alias Phoenix.PubSub
  use PollingAppWeb, :live_view

  alias PollingApp.Polls
  alias PollingApp.Polls.{Option, Poll}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(PollingApp.PubSub, "polls")
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
    |> assign(:poll, %Poll{options: [%Option{}]})
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
  def handle_info(:vote, socket) do
    {:noreply, stream(socket, :polls, Polls.list_polls())}
  end

  def handle_info(:vote, socket) do
    {:noreply, stream(socket, :polls, Polls.list_polls())}
  end

  def handle_info(:new, socket) do
    {:noreply,
     socket |> put_flash(:info, "New poll available") |> stream(:polls, Polls.list_polls())}
  end

  def handle_info(:updated, socket) do
    {:noreply,
     socket |> put_flash(:info, "Poll has been updated") |> stream(:polls, Polls.list_polls())}
  end

  def handle_info({:deleted, poll}, socket) do
    {:noreply, socket |> put_flash(:info, "Poll has been deleted") |> stream_delete(:polls, poll)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Polls.get_poll(id)
    {:ok, _} = Polls.delete_poll(poll)

    {:noreply, stream_delete(socket, :polls, poll)}
  end
end
