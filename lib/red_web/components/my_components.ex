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
    <nav class="flex flex-wrap justify-between items-center bg-gray-800 text-white lg:px-8 sm:px-4 px-2">
      <a
        href="/"
        class="text-white whitespace-nowrap text-xl hover:text-grey-200 active:text-grey-400"
      >
        Spelling Tutor
      </a>
      <div class="flex flex-wrap justify-end items-center gap-3">
        <a href="/about" class="text-white hover:text-grey-200 active:text-grey-400">
          About
        </a>
        <%= if @current_user do %>
          <a
            href="/stats"
            class="text-white hover:text-grey-200 active:text-grey-400"
          >
            Stats
          </a>
          <img
            src={@current_user.picture}
            alt="Profile Picture"
            style="width:48px;height:48px;border-radius:50%;"
            class="my-1"
          />
          <a
            href="/sign-out"
            class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70"
          >
            Sign out
          </a>
        <% else %>
          <a
            href="/auth/user/auth0"
            class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70 my-3"
          >
            Sign In
          </a>
        <% end %>
      </div>
    </nav>
    """
  end
end
