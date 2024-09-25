defmodule PollingAppWeb.PollLive.Show do
  use PollingAppWeb, :live_view

  alias Phoenix.PubSub
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
        if connected?(socket), do: PubSub.subscribe(PollingApp.PubSub, "polls:#{id}")

        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:username, current_user.username)
         |> assign(:poll, poll)
         |> assign_new(:form, fn ->
           to_form(Polls.change_poll(poll))
         end)}
    end
  end

  @impl true
  def handle_event(
        "vote",
        %{"option_id" => option_id, "username" => username},
        socket
      ) do
    poll = socket.assigns.poll
    votes = poll.votes

    with {:ok, true} <- validate_vote(votes, username),
         {:ok, updated_poll} <- Polls.vote(poll, option_id, username) do
      # Notify all polls subscribers
      notify_subscribers("polls:#{poll.id}", {:vote, updated_poll})
      notify_subscribers("polls", :vote)

      {:noreply,
       socket |> put_flash(:info, "Vote added successfully") |> assign(:poll, updated_poll)}
    else
      {:error, :already_voted} ->
        {:noreply, socket |> put_flash(:error, "Already voted")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Polls.get_poll(id)
    {:ok, _} = Polls.delete_poll(poll)

    notify_subscribers("polls", {:deleted, poll})

    socket =
      socket
      |> put_flash(:info, "Poll has been deleted")
      |> stream(:polls, Polls.list_polls())
      |> push_navigate(to: ~p"/polls")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:vote, updated_poll}, socket) do
    {:noreply, assign(socket, :poll, updated_poll)}
  end

  @impl true
  def handle_info({:saved, updated_poll}, socket) do
    {:noreply, assign(socket, :poll, updated_poll)}
  end

  @impl true
  def handle_info({:updated, updated_poll}, socket) do
    {:noreply,
     socket |> put_flash(:info, "Options has been updated") |> assign(:poll, updated_poll)}
  end

  @impl true
  def handle_info({_module, {:saved, poll}}, socket) do
    {:noreply, assign(socket, :poll, poll)}
  end

  defp page_title(:show), do: "Show Poll"
  defp page_title(:edit), do: "Edit Poll"

  defp notify_subscribers(channel, msg), do: PubSub.broadcast(PollingApp.PubSub, channel, msg)

  defp validate_vote(votes, username) do
    votes = Enum.map(votes, & &1.username)

    if username in votes do
      {:error, :already_voted}
    else
      {:ok, true}
    end
  end
end
