defmodule Echo.Repo.Migrations.AddUniqueIndexToDictionaryTable do
  use Ecto.Migration

  def change do
    create index("dictionary", :key, unique: true)
  end
end
