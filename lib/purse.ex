defmodule Purse do
  use GenServer

  # Client

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def deposit(purse, currency, amount) do
    GenServer.call(purse, {:deposit, currency, amount})
  end

  def withdraw(purse, currency, amount) do
    GenServer.call(purse, {:withdraw, currency, amount})
  end

  def peek(purse, currency) do
    GenServer.call(purse, {:peek, currency})
  end

  def peek(purse) do
    GenServer.call(purse, :peek)
  end

  # Server

  def init(name) do
    file = ~c"/tmp/purse_#{name}"
    {:ok, table} = :dets.open_file(name, type: :set, file: file)
    {:ok, %{table: table}}
  end

  def handle_call({:deposit, currency, amount}, _from, %{table: table} = state) do
    case lookup(table, currency) do
      nil -> insert(table, currency, amount)
      current -> insert(table, currency, amount + current)
    end

    {:reply, :ok, state}
  end

  def handle_call({:withdraw, currency, amount}, _from, %{table: table} = state) do
    res = case lookup(table, currency) do
      nil -> {:error, "No such currency in your purse"}
      current when current >= amount -> {:ok, insert(table, currency, current - amount)}
      _ -> {:error, "Not enough #{currency}"}
    end

    {:reply, res, state}
  end

  def handle_call(:peek, _from, %{table: table} = state) do
    {:reply, {:ok, lookup(table)}, state}
  end

  def handle_call({:peek, currency}, _from, %{table: table} = state) do
    res = case lookup(table, currency) do
            nil -> {:error, "No such currency"}
            current -> {:ok, current}
          end
    {:reply, res, state}
  end

  defp lookup(table) do
    Map.new(:dets.match_object(table, :_))
  end

  defp lookup(table, currency) do
    case :dets.lookup(table, currency) do
      [{^currency, amount}] -> amount
      _ -> nil
    end
  end

  defp insert(table, currency, amount) do
    :dets.insert(table, {currency, amount})
  end

end
