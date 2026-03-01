defmodule Automations.LightLogger do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init({:ok, pid}) do
    {:ok, %{state: "unknown", pid: pid}}
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def set_entity(%{"entity_id" => "light.living_room", "state" => state}) do
    GenServer.cast(__MODULE__, {:set_state, state})
  end

  def set_entity(_) do
    :ok
  end

  def change_entity(_, %{"entity_id" => "light.living_room", "state" => new_state}) do
    GenServer.call(__MODULE__, {:change_state, new_state})
  end

  def handle_call(:get_state, _from, %{state: state} = data) do
    {:reply, {state}, data}
  end

  def handle_call({:change_state, new_state}, _from, %{state: old_state, pid: pid} = data) do
    if new_state != old_state do
      send(
        pid,
        {self(),
         {:send,
          {:text,
           %{
             domain: "persistent_notification",
             service: "create",
             service_data: %{message: "The living room light is #{new_state}"}
           }}}}
      )
    end

    {:reply, :ok, %{data | state: new_state}}
  end

  def handle_cast({:set_state, new_state}, data) do
    {:noreply, %{data | state: new_state}}
  end
end
