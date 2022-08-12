defmodule Purse do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  @impl GenServer
  def init(name) do
    file = String.to_charlist("/tmp/purse_#{name}")
    table = :dets.open_file(name, [{:file, file}])
    {:ok, %{table: table}}
  end
end
