defmodule SteerWeb.ChannelLive.ChannelItemComponent do
  use Phoenix.Component

  import SteerWeb.Components.NodeStatusIndicatorComponent

  def channel_item(assigns) do
    %{channel: channel} = assigns

    ~H"""
    <div>

      <div x-data={"{ pubKey: '#{channel.node_pub_key}' }"}
        class="list-component-channel"
        style={"border-color:#{channel.color}"}>
        <div class="w-max px-2">
          <div class="flex">
            <.node_status_indicator status={channel.status} />
            <div class="text-xl text-gray-300 text-opacity-80 w-auto font-nodename" phx-click="">
              <%= channel.alias %>
            </div>
          </div>
          <div class="text-xs text-gray-500 w-aut0">
            <%= channel.formatted_node_pub_key %>
            <template x-if="window.location.protocol === 'https:'">
              <button @click.stop @click="event.preventDefault();$clipboard(pubKey);">
                <img src="/images/clipboard.svg">
              </button>
            </template>
          </div>
          <div class="text-xs">
            <span class="text-base"><%= channel.forward_in_count + channel.forward_out_count %></span> forwards
            <%= if channel.latest_forward_time != nil do %>
              <span>
                <%= Timex.from_now(channel.latest_forward_time) %>
              </span>
            <% end %>
          </div>
        </div>
        <div class="w-28 px-2">
          <div class="flex flex-row">
            <div class="text-right text-xs inline-block align-middle mr-1 pt-1 flex-none"><%= channel.formatted_capacity %></div>
            <div class="text-right text-xs inline-block align-middle pt-1 flex-grow"><%= channel.formatted_balance_percent %>%</div>
          </div>
          <div class="w-full filter drop-shadow-sm">
            <div class="rounded-xl w-full bg-gray-500">
              <div class="bg-green-600 rounded-xl py-1"
                style="width: {channel.formatted_balance_percent}%"></div>
            </div>
          </div>
        </div>
      </div>

    </div>
    """
  end
end
