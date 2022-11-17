defmodule Mix.Tasks.Start do
  @moduledoc "The start mix task: `mix help start`"
  use Mix.Task

  @shortdoc "Start exo server on 6000 port."
  def run(_) do
    Echo.Server.start(6000)
  end

end
