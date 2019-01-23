defmodule Ellie.Domain.Embed do
  alias Elm.Error
  alias Ellie.Types.Revision

  @type status :: :working | {:finished, Error.t | nil} | {:started, (-> Task.t)}

  @callback result(revision :: Revision.t) :: {:ok, Path.t} | :error
  @callback compile(revision :: Revision.t) :: status
  @callback cleanup(minutes_old :: integer) :: :unit

  @spec result(revision :: Revision.t) :: {:ok, Path.t} | :error
  def result(revision) do
    adapter().result(revision)
  end

  @spec compile(revision :: Revision.t) :: status
  def compile(revision) do
    adapter().compile(revision)
  end

  @spec cleanup(minutes_old :: integer) :: :unit
  def cleanup(minutes_old) do
    adapter().cleanup(minutes_old)
  end

  defp adapter() do
    config = Application.get_env(:ellie, Ellie.Domain.Embed, [])
    Keyword.get(config, :adapter, Ellie.Adapters.Embed.Local)
  end
end
