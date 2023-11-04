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
    <nav class="flex justify-between items-center bg-gray-800 text-white px-3">
      <a
        href="/"
        class="text-white text-xl pl-2 hover:text-grey-200 active:text-grey-400"
      >
        Spelling Tutor
      </a>
      <div class="flex justify-end items-center gap-3">
        <a href="/about" class="text-white hover:text-grey-200 active:text-grey-400">
          About
        </a>
        <%= if @current_user do %>
          <img
            src={@current_user.picture}
            alt="Profile Picture"
            style="width:50px;height:50px;border-radius:50%;"
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
            class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70"
          >
            Sign In
          </a>
        <% end %>
      </div>
    </nav>
    """
  end
end
