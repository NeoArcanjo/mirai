defmodule PollingApp.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PollingApp.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import PollingApp.DataCase
    end
  end

  setup do
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
