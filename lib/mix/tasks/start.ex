defmodule Mix.Tasks.Start do
  @moduledoc "The start mix task: `mix help start`"
  use Mix.Task

  @shortdoc "Start exo server on 6000 port."
  def run(args) do
    Mix.Task.run "app.start" # for using config/config.exs

    IO.inspect(args, label: "Received args")
    Echo.Server.start(6000)
  end

end
