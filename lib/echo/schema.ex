defmodule Echo.Schema do
  use Ecto.Schema

  schema "dictionary" do
    field :key, :string
    field :value, :string
    timestamps()
  end
end
