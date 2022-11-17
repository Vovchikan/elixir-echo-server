defmodule Echo.Server do

  require Logger

  @spec start(:inet.port_number()) :: no_return
  def start(port) do
    IO.puts(:stdio, ~s"Start tcp echo server on port = #{port}")
    tcp_options = [:binary, {:packet, 0}, {:active, false}]
    {:ok, socket} = :gen_tcp.listen(port, tcp_options)
    listen(socket)
  end

  @spec listen(:gen_tcp.socket()) :: no_return
  defp listen(socket) do
    Logger.notice :io_lib.format("LS=~p: Waiting accept", [socket])
    {:ok, conn} = :gen_tcp.accept(socket)
    spawn(fn -> recv(conn) end)
    listen(socket)
  end

  @spec recv(:gen_tcp.socket()) :: no_return
  defp recv(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, <<"stop\r\n">>} ->
        Logger.notice :io_lib.format("S=~p: Received stop", [conn])
        :gen_tcp.close (conn)
        :ok
      {:ok, data} ->
        Logger.info :io_lib.format("S=~p: Received data with len = ~p",
                                   [conn, byte_size(data)])
        Logger.debug :io_lib.format("data = ~p", [data])
        :gen_tcp.send(conn, data)
        recv(conn)
      {:error, :closed} ->
        :ok
    end
  end
end
