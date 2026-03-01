defmodule HomeAssistantEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, automations) do
    client = [
      # Starts a worker by calling: HomeAssistantEngine.Worker.start_link(arg)
      {HomeAssistantEngine, {"ws://192.168.0.204:8123/api/websocket", automations}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeAssistantEngine.Supervisor]
    Supervisor.start_link(client, opts)
  end
end
