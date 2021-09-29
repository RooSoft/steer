defmodule Steer.LndConnection do
  def initiate(page_pid) do
    send(page_pid, :connecting)

    spawn(fn ->
      case Steer.Lightning.connect() do
        :ok ->
          send(page_pid, { :dispatch_message, "Trying to connect to the node..." })

          Steer.Lightning.sync()
          Steer.Lightning.update_cache()

          send(page_pid, { :dispatch_message, "Node connection successful" })
        _ ->
          send(page_pid, { :dispatch_message, "Node connection failed" })
      end

      send(page_pid, :done_connecting)
    end)
  end
end
