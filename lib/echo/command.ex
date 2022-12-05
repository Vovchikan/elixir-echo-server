defmodule Echo.Command do
  import Ecto.Query
  alias Echo.{Repo, Schema}
  require Logger
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> Echo.Command.parse("CREATE KEY shopping\r\n")
      {:ok, {:create_key, "shopping"}}

      iex>Echo.Command.parse("ADD shopping milk\r\n")
      {:ok, {:add, {"shopping", "milk"}}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

    iex> Echo.Command.parse "UNKNOWN books gloves\r\n"
    {:error, :unknown_command}

    iex> Echo.Command.parse "INSERT shopping\r\n"
    {:error, :unknown_command}

"""
  def parse(line) do
    case String.split(line) do
      ["CREATE", "KEY", key] -> {:ok, {:create_key, key}}
      ["ADD", key, value] -> {:ok, {:add, {key, value}}}
      _ -> {:error, :unknown_command}
    end
  end

  def run(command)
  def run({:create_key, key}) when is_binary(key) do
    Logger.debug("CREATE KEY - #{inspect key}")

    from(d in "dictionary", where: d.key == ^key)
    |> Repo.delete_all
    schema = %Schema{key: key}
    Repo.insert(schema)
    {:ok, "Created key - #{key}\r\n"}
  end

  def run({:add, {key, value}}) when is_binary(key) do
    Logger.debug("ADD NEW VALUE - #{inspect value}")
    {count, _} = from(d in "dictionary", where: d.key == ^key)
    |> Repo.update_all(set: [value: value])
    {:ok, "Updated #{count} lines in db\r\n"}
  end
  def run(command) do
    Logger.debug("command = #{inspect command}")
    {:ok, "NOT IMPLEMENTED\r\n"}
  end
end
