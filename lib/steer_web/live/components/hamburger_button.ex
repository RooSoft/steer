defmodule SteerWeb.Components.HamburgerButton do
  use Phoenix.Component

  def hamburger_button(assigns) do
    ~H"""
    <div id="hamburgerButton" @click.stop="isSidebarOpen = !isSidebarOpen">
      <span class="sr-only">Open main menu</span>
      <div class="enclosure">
        <span class="bar high-bar" :class="isSidebarOpen && 'active'"></span>
        <span class="bar mid-bar" :class="isSidebarOpen && 'active'"></span>
        <span class="bar low-bar" :class="isSidebarOpen && 'active'"></span>
      </div>
    </div>
    """
  end
end
