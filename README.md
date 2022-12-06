### FORK for leaning Elixir (Mix, OTP, Ecto) & Docker

# Echo server in Elixir

## TCP Server
There is a Erlang module called gen_tcp that we'll use to for communicating
with TCP sockets.

In ```lib/echo/server.ex``` we have the module responsible for that. It starts
a server

```elixir
def start(port) do
  tcp_options = [:binary, {:packet, 0}, {:active, false}]
  {:ok, socket} = :gen_tcp.listen(port, tcp_options)
  listen(socket)
end
```

then loop forever accepting income connections

```elixir
  @spec listen(:gen_tcp.socket()) :: no_return
  defp listen(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      Echo.TaskSupervisor, fn -> serve(conn) end)
    :ok = :gen_tcp.controlling_process(conn, pid)
    listen(socket)
  end
```

when a client connects it spawns a new process by module Task, addes it to Supervisor and starts receiving data
from the new made connection

```elixir
defp serve(socket) do
  msg =
    with {:ok, data} <- read_line(socket),
         {:ok, command} <- Echo.Command.parse(data),
         do: Echo.Command.run(command)

  write_line(socket, msg)
  serve(socket)
end
```

## Running on the console.
To run this open a console and start the server.

```shell
$ iex -S mix
iex> Echo.Server.start(6000)
```

The ```-S mix``` options will load your project into the current session.

Connect using telnet or netcat and try it out.

## Running on the docker container.
To do this open a console, go to project dir and build image.

```shell
$ make image
```

Then run container.

```shell
$ make run
```

or in detached mode.

```shell
$ make run-detached
```

Connect using telnet.

```shell
$ make telnet
```

## Example
```shell
$ telnet localhost 6000
Trying ::1...
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
READ

Result:
KEY - VALUE
test3 - value3
test2 - value2
test1 - value1

DELETE test3
OK
READ

Result:
KEY - VALUE
test2 - value2
test1 - value1

DELETE ALL
2 entries have been removed
READ

Result:
KEY - VALUE
```

For more available commands see [Echo.Command](./lib/echo/command.ex) module


## Automating tasks
Create a ```lib/mix/tasks/start.ex``` file and a module called ```Mix.Tasks.Start```. The
```run``` function will be called by mix when we invoke the task.

```elixir
def run(args) do
    Mix.Task.run "app.start" # for starting deps (like ecto)

    port =
      with [port] <- args,
           {number, _} <- Integer.parse(port)
         do number
      else
        _ -> 6000
      end
    Echo.Server.start(port)
  end
```

Compile your app and start the server

```shell
$ mix deps.get
$ mix compile
$ mix ecto.setup
$ mix start
```

or
```shell
$ mix do deps.get, compile, ecto.setup, start
```
## Deps
PostgreSQL on local machine