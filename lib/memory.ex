defmodule Memory do
  @moduledoc """
  Memory keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Memory.Repo, []),
      supervisor(Memory.Endpoint, [])
      #worker(Memory.BackupChannel.Monitor, [%{}])
    ]
  end
end
