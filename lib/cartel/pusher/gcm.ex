defmodule Cartel.Pusher.Gcm do
  @moduledoc """
  Google GCM interface worker
  """

  use GenServer
  use Cartel.Pusher, message_module: Cartel.Message.Gcm

  alias Cartel.Message.Gcm

  @gcm_server_url "https://gcm-http.googleapis.com/gcm/send"

  def start_link(args), do: GenServer.start_link(__MODULE__, args, [])

  def init(conf = %{type: __MODULE__}), do: {:ok, conf}

  @doc """
  Sends the message via the specified worker process
  """
  @spec push(pid, Gcm.t) :: :ok | :error
  def push(pid, message), do: GenServer.call(pid, {:push, message})

  def handle_call({:push, message}, _from, state) do
    {:ok, request} = Message.serialize(message)
    headers = [
      "Content-Type": "application/json",
      "Authorization": "key=" <> state[:key]
    ]
    res = HTTPotion.post(@gcm_server_url, [body: request, headers: headers])
    respond(res, state)
  end

  defp respond(res = %HTTPotion.Response{status_code: code}, state)
  when code >= 400 do
    {:stop, res.code, state}
  end

  defp respond(res = %HTTPotion.Response{}, state) do
    {:reply, {:ok, res.status_code, Poison.decode(res.body)}, state}
  end
end
