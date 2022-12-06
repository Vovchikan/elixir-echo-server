defmodule Echo.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Echo.Repo,
      {Task.Supervisor, name: Echo.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
