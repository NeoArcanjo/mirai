defmodule PollingApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    start_agents()

    children = [
      PollingAppWeb.Telemetry,
      {DynamicSupervisor, name: PollingApp.DataLayerSupervisor, strategy: :one_for_one},
      {DNSCluster, query: Application.get_env(:polling_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PollingApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PollingApp.Finch},
      # Start a worker by calling: PollingApp.Worker.start_link(arg)
      # {PollingApp.Worker, arg},
      # Start to serve requests, typically the last entry
      PollingAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollingApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PollingAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp start_agents do
    {:ok, _} = Registry.start_link(keys: :unique, name: PollingApp.Registry)

    polls = {:via, Registry, {PollingApp.Registry, :polls}}

    {:ok, _} = PollingApp.DataLayer.start_link(name: polls)

    users = {:via, Registry, {PollingApp.Registry, :users}}
    {:ok, _} = PollingApp.DataLayer.start_link(name: users)

    sessions = {:via, Registry, {PollingApp.Registry, :sessions}}
    {:ok, _} = PollingApp.DataLayer.start_link(name: sessions)

    :ok
  end
end
