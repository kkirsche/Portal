defmodule Portal do
  use Application

  defstruct [:left, :right]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Portal.Door, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    # We have changed the strategy from :one_for_one to :simple_one_for_one.
    # Supervisors provide different strategies and :simple_one_for_one is useful
    # when we want to dynamically create children, often with different arguments.
    # This is exactly the case for our portal doors, where we want to spawn
    # multiple doors with different colors.
    opts = [strategy: :simple_one_for_one, name: Portal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Shoots a new door with the given `color`.
  """
  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end

  @doc """
  Starts transfering `data` from `left` to `right`.
  """
  def transfer(left, right, data) do
    # First, add all the data to the portal on the left
    for item <- data do
      Portal.Door.push(left, item)
    end

    # Returns a portal struct we will use next.
    %Portal{left: left, right: right}
  end

  @doc """
  Pushes data to the left in the given `portal`.
  """
  def push_left(portal) do
    response_portal = push("left", portal)
    response_portal
  end

  @doc """
  Pushes data to the right in the given `portal`.
  """
  def push_right(portal) do
    response_portal = push("right", portal)
    response_portal
  end

  @doc """
  Reduce duplication by providing a single method between pushing functions.
  """
  def push(direction, portal) do
    case direction do
      # See if we can pop data from right. If so, push the popped data to the
      # left. Otherwise, do nothing.
      "left"  -> case Portal.Door.pop(portal.right) do
          :error    -> :ok
          {:ok, h}  -> Portal.Door.push(portal.left, h)
        end
      # See if we can pop data from left. If so, push the popped data to the
      # right. Otherwise, do nothing.
      "right" -> case Portal.Door.pop(portal.left) do
          :error    -> :ok
          {:ok, h}  -> Portal.Door.push(portal.right, h)
        end
      _ -> raise "We got an illegal direction! Exiting, Mr. Supervisor, please restart me!"
    end

    # Let's return the portal
    portal
  end
end

defimpl Inspect, for: Portal do
  def inspect(%Portal{left: left, right: right}, _) do
    left_door = inspect(left)
    right_door = inspect(right)

    left_data = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))

    max = max(String.length(left_door), String.length(left_data))

    """
    #Portal<
      #{String.rjust(left_door, max)} <=> #{right_door}
      #{String.rjust(left_data, max)} <=> #{right_data}
    >
    """
  end
end
