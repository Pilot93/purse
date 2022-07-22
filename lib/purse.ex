defmodule PurseServer do
  use GenServer

  def start do
    GenServer.start(PurseServer, nil)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = TodoList.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {
      :reply,
      TodoList.entries(todo_list, date),
      todo_list
    }
  end
end

defmodule Purse do
  @moduledoc """Implement purse that can hold money and can deposit or withdraw
  in different currencies"""
  defstruct auto_id: 1, accounts: %{}

  def new(accounts \\ []) do
    Enum.reduce(
      accounts,
      %Purse{},
      &add_account(&2, &1)
    )
    IO.puts("You can deposit or withdraw in currencies: HIV, PIV, SIC")
  end

  def deposit(purse, currency, amount) do
    %Purse{purse | deposit: purse.deposit + currencies.currency * amount}
  end

  def withdraw(purse, currency, amount) when purse.deposit > amount do
    %Purse{purse | deposit: purse.deposit - currencies.currency * amount}
  end
end

