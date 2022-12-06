defmodule Echo.Command do
  import Ecto.Query
  import Ecto.Changeset
  alias Echo.{Repo, Schema}
  require Logger
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> Echo.Command.parse("CREATE animal cat\r\n")
      {:ok, {:create, %{key: "animal", value: "cat"}}}

      iex> Echo.Command.parse("READ\r\n")
      {:ok, {:read, :all}}

      iex> Echo.Command.parse("READ key\r\n")
      {:ok, {:read, "key"}}

      iex> Echo.Command.parse("UPDATE key value\r\n")
      {:ok, {:update, "key", "value"}}

      iex> Echo.Command.parse("DELETE ALL\r\n")
      {:ok, {:delete, :all}}

      iex> Echo.Command.parse("DELETE key\r\n")
      {:ok, {:delete, "key"}}

      iex>Echo.Command.parse("EXIT\r\n")
      {:error, :closed}

  Unknown commands or commands with the wrong number of
  arguments return an error:

    iex> Echo.Command.parse "UNKNOWN books gloves\r\n"
    {:error, :unknown_command}

    iex> Echo.Command.parse "INSERT shopping\r\n"
    {:error, :unknown_command}

"""
  def parse(line) do
    case String.split(line) do
      ["CREATE", key, value] -> {:ok, {:create, %{key: key, value: value}}}
      ["READ"] -> {:ok, {:read, :all}}
      ["READ", key] -> {:ok, {:read, key}}
      ["UPDATE", key, value] -> {:ok, {:update, key, value}}
      ["DELETE", "ALL"] -> {:ok, {:delete, :all}}
      ["DELETE", key] -> {:ok, {:delete, key}}
      ["EXIT"] -> {:error, :closed}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:create, params}) when is_map(params) do
    changeset =
      %Schema{}
      |> cast(params, [:key, :value])
      |> validate_required([:key, :value])
      |> unique_constraint(:key)
    case Repo.insert(changeset) do
      {:ok, _} -> {:ok, "OK\r\n"}
      {:error, changeset} ->
        {:error, {:reason, "#{inspect changeset.errors}"}}
    end
  end

  def run({:read, :all}) do
    result = Schema
             |> Repo.all
             |> List.foldr("KEY - VALUE\n",
              fn (%Schema{key: key, value: value}, acc) ->
                "#{acc}#{key} - #{value}\n"
              end)
    {:ok, "\nResult:\n#{result}\r\n"}
  end

  def run({:read, key}) when is_binary(key) do
    case Repo.get_by(Schema, key: key) do
      nil -> {:error, {:reason, "no entries with KEY #{key}"}}
      row -> {:ok, "\nvalue: #{row.value}\r\n"}
    end
  end

  def run({:update, key, value}) when is_binary(key) and is_binary(value) do
    {count, _} = from(d in "dictionary", where: d.key == ^key)
    |> Repo.update_all(set: [value: value])
    {:ok, "Updated #{count} lines in db\r\n"}
  end

  def run({:delete, :all}) do
    {entries, _} = Repo.delete_all(Schema)

    {:ok, "#{entries} entries have been removed\r\n"}
  end

  def run({:delete, key}) when is_binary(key) do
    try do
      case Repo.get_by!(Schema, key: key) |> Repo.delete do
        {:ok, _} ->
          {:ok, "OK\r\n"}
        {:error, changeset} ->
          {:error, {:reason, "#{inspect changeset.errors}"}}
      end
    rescue
      Ecto.NoResultsError -> {:ok, "OK\r\n"}
    end
  end

  def run(command) do
    Logger.debug("command = #{inspect command}")
    {:ok, "NOT IMPLEMENTED\r\n"}
  end
end
