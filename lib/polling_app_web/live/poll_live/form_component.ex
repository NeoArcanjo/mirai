defmodule PollingAppWeb.PollLive.FormComponent do
  use PollingAppWeb, :live_component

  alias Phoenix.PubSub
  alias PollingApp.Polls

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage poll records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />

        <h2 class="pt-4 font-medium text-gray-900">Options</h2>
        <div class="mt-2 flex flex-col">
          <.inputs_for :let={option} field={@form[:options]}>
            <input type="hidden" name="poll[options_sort][]" value={option.index} />

            <div class="flex items-center width-full">
              <.input field={option[:value]} type="text" placeholder="Option" />
              <label>
                <input
                  type="checkbox"
                  name="poll[options_drop][]"
                  value={option.index}
                  class="hidden"
                />
                <.icon
                  name="hero-x-mark"
                  class="w-8 h-8 relative top-4 bg-red-500 hover:bg-red-700 hover:cursor-pointer"
                />
              </label>
            </div>
          </.inputs_for>
        </div>

        <input type="hidden" name="poll[options_drop][]" />

        <:actions>
          <label class={[
            "py-2 px-3 inline-block cursor-pointer bg-green-500 hover:bg-green-700",
            "rounded-lg text-center text-white text-sm font-semibold leading-6"
          ]}>
            <input type="checkbox" name="poll[options_sort][]" class="hidden" /> Add Option
          </label>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{poll: poll, username: username} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:username, username)
     |> assign_new(:form, fn ->
       to_form(Polls.change_poll(poll))
     end)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset = Polls.change_poll(socket.assigns.poll, poll_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    poll_params = Map.put(poll_params, "created_by", socket.assigns.username)
    save_poll(socket, socket.assigns.action, poll_params)
  end

  defp save_poll(socket, :edit, poll_params) do
    case Polls.update_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})
        notify_subscribers("polls:#{poll.id}", {:updated, poll})
        notify_subscribers("polls", :updated)

        {:noreply,
         socket
         |> put_flash(:info, "Poll updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_poll(socket, :new, poll_params) do
    case Polls.create_poll(poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})
        notify_subscribers("polls:#{poll.id}", {:saved, poll})
        notify_subscribers("polls", :new)

        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
  defp notify_subscribers(channel, msg), do: PubSub.broadcast(PollingApp.PubSub, channel, msg)
end
