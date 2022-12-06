alias Echo.Repo
alias Echo.Schema

Repo.insert! %Schema{
  key: "test1",
  value: "value1"
}
Repo.insert! %Schema{
  key: "test2",
  value: "value2"
}
Repo.insert! %Schema{
  key: "test3",
  value: "value3"
}
