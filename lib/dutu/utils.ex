defmodule Dutu.Utils do
  def ensure_map(%{__struct__: _} = struct), do: Map.from_struct(struct)
  def ensure_map(map), do: map
end
