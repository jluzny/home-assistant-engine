defmodule Automations.LightLoggerTest do
  use ExUnit.Case

  setup do
    start_supervised!({Automations.LightLogger, {:ok, self()}})
    :ok
  end

  test "use unknown for initial state" do
    assert Automations.LightLogger.get_state() == {"unknown"}
  end

  test "saves the state of light.living_room entity" do
    Automations.LightLogger.set_entity(%{"entity_id" => "light.living_room", "state" => "on"})

    assert Automations.LightLogger.get_state() == {"on"}
  end

  test "does not change the state for other entities" do
    Automations.LightLogger.set_entity(%{
      "entity_id" => "other.entity",
      "state" => "something_else"
    })

    assert Automations.LightLogger.get_state() == {"unknown"}
  end

  test "handles multiple calls" do
    Automations.LightLogger.set_entity(%{"entity_id" => "light.living_room", "state" => "on"})
    Automations.LightLogger.set_entity(%{"entity_id" => "light.living_room", "state" => "off"})

    Automations.LightLogger.set_entity(%{
      "entity_id" => "other.entity",
      "state" => "something_else"
    })

    assert Automations.LightLogger.get_state() == {"off"}
  end

  test "handles change entity action" do
    Automations.LightLogger.set_entity(%{"entity_id" => "light.living_room", "state" => "off"})

    Automations.LightLogger.change_entity(%{}, %{
      "entity_id" => "light.living_room",
      "state" => "on"
    })

    assert Automations.LightLogger.get_state() == {"on"}

    assert_received {_,
                     {:send,
                      {:text,
                       %{
                         domain: "persistent_notification",
                         service: "create",
                         service_data: %{message: "The living room light is on"}
                       }}}}
  end

  test "handles change entity action when the state remained the same" do
    Automations.LightLogger.set_entity(%{"entity_id" => "light.living_room", "state" => "off"})

    Automations.LightLogger.change_entity(%{}, %{
      "entity_id" => "light.living_room",
      "state" => "off"
    })

    assert Automations.LightLogger.get_state() == {"off"}
    refute_received {_, {:send, {:text, _}}}
  end
end
