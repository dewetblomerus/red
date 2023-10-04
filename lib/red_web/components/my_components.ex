defmodule RedWeb.MyComponents do
  @moduledoc """
  Because this is a basic side-project, I'm not going to modify
  core_components.ex too much.
  Instead, I created this file to hold shared components.
  """

  use Phoenix.Component

  # alias Phoenix.LiveView.JS
  # import RedWeb.Gettext

  @doc """
  Renders a Navbar

  ## Examples

      <.navbar current_user={@current_user} />
  """
  attr :current_user, :map

  def navbar(assigns) do
    ~H"""
    <nav class="bg-gray-800">
      <div class="px-2 mx-auto max-w-7xl sm:px-6 lg:px-8">
        <div class="relative flex items-center justify-between h-16">
          <div class="flex items-center justify-center flex-1 sm:items-stretch sm:justify-start">
            <div class="block ml-6">
              <div class="flex space-x-4">
                <div class="px-3 py-2 text-xl font-medium text-white ">
                  Red Words
                </div>
              </div>
            </div>
          </div>
          <div class="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
            <%= if @current_user do %>
              <span class="px-3 py-2 text-sm font-medium text-white rounded-md">
                <%= @current_user.email %>
              </span>
              <a
                href="/sign-out"
                class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70"
              >
                Sign out
              </a>
            <% else %>
              <a
                href="/sign-in"
                class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70"
              >
                Sign In
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </nav>
    """
  end
end
