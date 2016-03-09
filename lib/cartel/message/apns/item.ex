defmodule Cartel.Message.Apns.Item do
  defstruct [:id, :data]
  alias Cartel.Message.Apns.Item

  @device_token 1
  def device_token, do: @device_token

  @payload 2
  def payload, do: @payload

  @notification_identifier 3
  def notification_identifier, do: @notification_identifier

  @expiration_date 4
  def expiration_date, do: @expiration_date

  @priority 5
  def priority, do: @priority

  @priority_immediately 10
  def priority_immediately, do: @priority_immediately

  @priority_when_convenient 5
  def priority_when_convenient, do: @priority_when_convenient

  def encode(item = %Item{id: @device_token}) do
    {:ok, token} = Base.decode16(item.data, case: :mixed)
    {:ok, <<item.id::size(8), 32::size(16)>> <> token}
  end

  def encode(item = %Item{id: @payload}) do
    {:ok, msg_payload} = Poison.encode(item.data)
    payload_size = byte_size(msg_payload)
    {:ok, <<item.id::size(8), payload_size::size(16)>> <> msg_payload}
  end

  def encode(item = %Item{id: @notification_identifier}) do
    {:ok, <<item.id::size(8), 4::size(16), item.data::size(32)>>}
  end

  def encode(item = %Item{id: @expiration_date}) do
    date = item.data
    if date == nil do
      date = 0
    end
    {:ok, <<item.id::size(8), 4::size(16), date::size(32)>>}
  end

  def encode(item = %Item{id: @priority}) do
    msg_priority = item.data
    if msg_priority == nil do
      msg_priority = @priority_immediately
    end
    {:ok, <<item.id::size(8), 1::size(16), msg_priority::size(32)>>}
  end
end