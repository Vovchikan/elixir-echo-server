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
defp listen(socket) do
  {:ok, conn} = :gen_tcp.accept(socket)
  spawn(fn -> recv(conn) end)
  listen(socket)
end
```

when a client connects it spawns a new process and start receiving data
from the new made connection

```elixir
defp recv(conn) do
  case :gen_tcp.recv(conn, 0) do
    {:ok, data} ->
      :gen_tcp.send(conn, data)
      recv(conn)
    {:error, :closed} ->
      :ok
  end
end
```

to close connection with server, client should write `stop`

```elixir
    case :gen_tcp.recv(conn, 0) do
      {:ok, <<"stop\r\n">>} ->
        :gen_tcp.close (conn)
        :ok
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
$ telnet localhost 400
```


## Automating tasks
Create a ```lib/mix/tasks/start.ex``` file and a module called ```Mix.Tasks.Start```. The
```run``` function will be called by mix when we invoke the task.

```elixir
def run(_) do
  Echo.Server.start(6000)
end
```

Compile your app and start the server

```shell
$ mix deps.get
$ mix compile
$ mix start
```

or
```shell
$ mix do deps.get, compile, start
```
