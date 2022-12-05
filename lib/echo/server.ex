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
    spawn(fn -> serve(conn) end)
    listen(socket)
  end

  defp serve(socket) do
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- Echo.Command.parse(data),
           do: Echo.Command.run(command)

    write_line(socket, msg)
    serve(socket)
  end

  @spec read_line(:gen_tcp.socket()) :: no_return
  defp read_line(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, data}=result ->
        Logger.info(fn -> "S=#{inspect conn}: Received data with len = #{inspect byte_size(data)}" end)
        Logger.debug(fn ->"data = #{inspect data}" end)
        result
      {:error, :closed}=result ->
        result
    end
  end

  defp write_line(socket, context)
  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    # Known error; write to the client
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(socket, {:error, :closed}) do
    # The connection was closed, exit politely
    :gen_tcp.close(socket)
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    # Unknown error; write to the client and exit
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
