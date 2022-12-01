defmodule Echo.Server do

  require Logger

  @spec start(:inet.port_number()) :: no_return
  def start(port) do
    Logger.notice(~s"Start tcp echo server on port = #{port}")

    tcp_options = [:binary, {:packet, 0}, {:active, false}]
    {:ok, socket} = :gen_tcp.listen(port, tcp_options)
    listen(socket)
  end

  @spec listen(:gen_tcp.socket()) :: no_return
  defp listen(socket) do
    Logger.notice(fn -> "LS=#{inspect socket}: Waiting accept" end)

    {:ok, conn} = :gen_tcp.accept(socket)
    spawn(fn -> recv(conn) end)
    listen(socket)
  end

  @spec recv(:gen_tcp.socket()) :: no_return
  defp recv(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, <<"stop\r\n">>} ->
        Logger.notice(fn -> "S=#{inspect conn}: Received stop" end)

        :gen_tcp.close (conn)
        :ok
      {:ok, data} ->
        Logger.info(fn -> "S=#{inspect conn}: Received data with len = #{inspect byte_size(data)}" end)
        Logger.debug(fn ->"data = #{inspect data}" end)

        :gen_tcp.send(conn, data)
        recv(conn)
      {:error, :closed} ->
        :ok
    end
  end
end
