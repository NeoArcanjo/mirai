defmodule PollingApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
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
      PollingAppWeb.Endpoint,
      Supervisor.child_spec({PollingApp.Registry, name: :users}, id: :users),
      Supervisor.child_spec({PollingApp.Registry, name: :polls}, id: :polls),
      Supervisor.child_spec({PollingApp.Registry, name: :sessions}, id: :sessions)
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
end
