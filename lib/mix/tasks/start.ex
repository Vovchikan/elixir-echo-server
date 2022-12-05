defmodule Mix.Tasks.Start do
  @moduledoc "The start mix task: `mix help start`"
  use Mix.Task

  @shortdoc "Start exo server on given port (def 6000)."
  def run(args) do
    Mix.Task.run "app.start" # for using config/config.exs

    port =
      with [port] <- args,
           {number, _} <- Integer.parse(port)
         do number
      else
        _ -> 6000
      end
    Echo.Server.start(port)
  end

end
