defmodule FuzzyDocSearch do
  @moduledoc """
  Documentation for FuzzyDocSearch.
  """
  import IEx.Helpers, only: [h: 1]

  defmacro z(term) do
    case search_contains(term) do
      [] ->
        not_found(term)

      [{mod, fun, _}] ->
        h({mod, fun})

      [{mod, fun, s1}, {_, _, s2} | _] = list when s1 > s2 ->
        h({mod, fun})
        many_found(tl(list))

      multiple ->
        many_found(multiple)
    end
  end

  defp search_contains({function_name, _, _}) do
    for mod <- get_modules(),
        fun <- get_functions(mod),
        score = score_function(mod, fun, function_name),
        score > 0.0 do
      {mod, fun, score}
    end
    |> Enum.sort(fn {_, _, s1}, {_, _, s2} -> s1 > s2 end)
  end

  defp score_function(mod, fun, function_name) do
    modscore = score_module(mod)

    cond do
      fun == function_name -> 1.0 - modscore
      contains?(fun, function_name) -> 0.8 - modscore
      true -> 0.0
    end
  end

  # Top level module
  # Elixir.String - 0
  # Elixir.String.Chars - 0.1
  # Elixir.String.Chars.Atom - 0.2
  # longer > - 0.4
  defp score_module(mod) do
    dots =
      mod
      |> Atom.to_string()
      |> String.graphemes()
      |> Enum.count(&(&1 == "."))

    min((dots - 1) / 10, 0.4)
  end

  defp contains?(fun, function_name) do
    String.contains?(Atom.to_string(fun), Atom.to_string(function_name))
  end

  defp get_modules() do
    {:ok, modules} = :application.get_key(:elixir, :modules)
    modules
  end

  defp get_functions(mod) do
    Enum.uniq(Keyword.keys(mod.module_info(:exports)))
  end

  defp not_found(term) do
    print_term = Macro.to_string(quote(do: unquote(term)))
    IO.puts("No function like '#{print_term}' was found")
    IEx.dont_display_result()
  end

  defp many_found(matches) do
    IO.puts([
      IO.ANSI.yellow_background(),
      IO.ANSI.black(),
      " Did you mean one of? \n",
      IO.ANSI.default_color(),
      IO.ANSI.default_background()
    ])

    matches
    |> Enum.take(5)
    |> Enum.each(fn {mod, fun, _} ->
      IO.puts(Macro.to_string(quote do: unquote(mod).unquote(fun)))
    end)

    IO.write("\n")

    IEx.dont_display_result()
  end
end
