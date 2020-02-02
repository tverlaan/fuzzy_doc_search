# FuzzyDocSearch

Example of how a 'fuzzy' function doc search could work in IEx. This feature tries to mirror the
functionality on [hexdocs](https://hexdocs.pm/elixir). There you can use the searchbox and start
typing to find your function.

## Examples

### Partial single match

```
iex> z jaro

                      def jaro_distance(string1, string2)                       

  @spec jaro_distance(t(), t()) :: float()

-snip (function doc)-

```

### Best matches with additional options

This works with a scoring mechanism. Exact match on function name scores best, partial match scores
worse. Function in a sub module gets points subtracted. Please read the code for the calculation.

```
iex(15)> z async

                                 def async(fun)                                 

  @spec async((() -> any())) :: t()

Starts a task that must be awaited on.

-snip (function doc)-

 Did you mean one of? 

Task.Supervisor.async()
Kernel.ParallelCompiler.async()
Task.async_stream()
Task.Supervisor.async_stream_nolink()
Task.Supervisor.async_stream()
```

### No matches

```
iex> z foo
No function like 'foo' was found
```

### Many matches

```
iex> z to_string
 Did you mean one of? 

URI.to_string()
Time.to_string()
NaiveDateTime.to_string()
Macro.to_string()
List.to_string()
```