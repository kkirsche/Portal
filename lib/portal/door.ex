defmodule Portal.Door do
  @doc """
  Starts the door with the given `color`.

  The color is given as a name so we can identify the door by color name
  instead of by PID.

  iex> Portal.Door.start_link(:red)
  {:ok, #PID<0.00.1>}
  """
  def start_link(color) do
    Agent.start_link(fn -> [] end, name: color)
  end

  @doc """
  Get the data currently in the `door`.

  iex> Portal.Door.get(:red)
  []
  """
  def get(door) do
    Agent.get(door, fn list -> list end)
  end

  @doc """
  Pushes the `value` into the door.

  iex> Portal.Door.push(:red, 1)
  :ok
  """
  def push(door, value) do
    Agent.update(door, fn list -> [value | list] end)
  end

  @doc """
  Pops a `value` from the `door`.

  Returns `{:ok, value}` if there is a value or `:error` if
  the hole is currently empty.

  iex> Portal.Door.pop(:red)
  {:ok, 1}
  :error
  """
  def pop(door) do
    Agent.get_and_update(door, fn
      []    -> {:error, []}
      [h|t] -> {{:ok, h}, t}
    end)
  end
end
