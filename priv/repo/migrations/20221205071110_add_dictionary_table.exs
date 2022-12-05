defmodule Echo.Repo.Migrations.AddDictionaryTable do
  use Ecto.Migration

  def change do
    create table("dictionary") do
      add :key, :string
      add :value, :string
      timestamps(type: :utc_datetime)
    end
  end
end
