from aocd import get_data, submit
import networkx as nx
import copy


def build_graph(dat):
    """
    dat is a string of ".", "#", and possibly a single "^",
    with newline characters to separate rows.
    We'll build a NetworkX graph (undirected) where each passable cell is a node,
    and edges exist between adjacent passable cells.
    """
    # Empty undirected Graph
    G = nx.Graph()
    direction_map = {"^": "up", "v": "down", "<": "left", ">": "right"}

    start_pos = None
    start_dir = None
    # Directions to move guard ("^, v, <, >")
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for y, row in enumerate(dat):
        for x, cell in enumerate(row):
            if cell != "#":
                G.add_node((y, x), cell=cell)
                if cell in direction_map:
                    start_pos = (y, x)
                    start_dir = direction_map[cell]
                    # treat starting cell as passable even if
                    # it contains startin symbol
                    G.nodes[(y, x)]["cell"] = "."  # Replace with floor if needed

                for dy, dx in directions:
                    ny, nx_ = y + dy, x + dx
                    if 0 <= ny < len(dat) and 0 <= nx_ < len(dat[ny]):
                        if dat[ny][nx_] != "#":
                            G.add_edge((y, x), (ny, nx_))

    return G, start_pos, start_dir


def sim_guard_move(G, dat, start_pos, start_dir):
    """
    Simulates the guard's movement based on the patrol protocol.

    Args:
        G (networkx.Graph): NetworkX graph representing the passable cells.
        dat (list of lists): Original map data as a list of lists (each sublist represents a row).
        start_pos (tuple): Tuple (y, x) indicating the starting position of the guard.
        start_dir (str): Initial direction the guard is facing ('up', 'right', 'down', 'left').

    Returns:
        tuple:
            - visited_positions (set): Set of tuples representing visited positions.
            - guard_left_map (bool): True if the guard left the map, False if stuck in a loop.
    """
    visited_positions = set()
    visited_states = set()

    current_pos = start_pos
    current_dir = start_dir

    visited_positions.add(current_pos)
    visited_states.add((current_pos, current_dir))

    # Define direction vectors
    direction_vectors = {
        "up": (-1, 0),
        "right": (0, 1),
        "down": (1, 0),
        "left": (0, -1),
    }

    # Define right turn mapping
    right_turn = {"up": "right", "right": "down", "down": "left", "left": "up"}

    while True:
        dy, dx = direction_vectors[current_dir]
        next_pos = (current_pos[0] + dy, current_pos[1] + dx)

        # Check if the next position is within the map boundaries
        if 0 <= next_pos[0] < len(dat) and 0 <= next_pos[1] < len(dat[next_pos[0]]):
            if G.has_node(next_pos):
                # Move forward if the next position is passable
                if G.has_edge(current_pos, next_pos):
                    current_pos = next_pos
                    visited_positions.add(current_pos)
                    state = (current_pos, current_dir)

                    # Check for loop
                    if state in visited_states:
                        return (visited_positions, False)
                    else:
                        visited_states.add(state)
                else:
                    # Edge does not exist; turn right
                    current_dir = right_turn[current_dir]
                    state = (current_pos, current_dir)

                    # Check for loop
                    if state in visited_states:
                        return (visited_positions, False)
                    else:
                        visited_states.add(state)
            else:
                # Next position is an obstacle; turn right
                current_dir = right_turn[current_dir]
                state = (current_pos, current_dir)

                # Check for loop
                if state in visited_states:
                    return (visited_positions, False)
                else:
                    visited_states.add(state)
        else:
            # Out of bounds; guard leaves the map
            return (visited_positions, True)


def find_loops(dat):
    """
    Finds the number of cells which, when blocked, allow the guard to leave the map without entering a loop.

    Args:
        dat (list of lists): Original map data as a list of lists.

    Returns:
        int: Number of cells that can be blocked to allow the guard to leave the map.
    """
    count = 0  # number of loops found
    direction_symbols = {"^", "v", "<", ">"}

    # Identify all starting positions to skip them
    start_positions = set()
    for y, row in enumerate(dat):
        for x, cell in enumerate(row):
            if cell in direction_symbols:
                start_positions.add((y, x))

    # Build the initial graph once
    G, st_ps, st_dr = build_graph(dat)

    # Validate starting position and direction
    if st_ps is None or st_dr is None:
        print("Error: Starting position or direction not found in the map.")
        return 0

    # Make a mutable copy of the graph to modify
    G_copy = G.copy()

    # Iterate over each cell in the map
    for y, row in enumerate(dat):
        for x, cell in enumerate(row):
            # Skip cells that are already obstacles or are starting positions
            if cell == "#" or (y, x) in start_positions:
                continue

            # Check if the node exists in the graph before attempting to remove
            if not G_copy.has_node((y, x)):
                # The cell is already blocked or was previously processed
                continue

            # Remove the node from the graph copy to simulate blocking the cell
            G_copy.remove_node((y, x))

            # Simulate the guard's movement on the modified graph
            visited_c, left_map = sim_guard_move(G_copy, dat, st_ps, st_dr)

            # If the guard left the map (did not loop), count this option
            if not left_map:
                count += 1

            # Re-add the node back to the graph to restore the original state
            G_copy.add_node((y, x), cell=cell)

            # Reconnect the node with its neighbors based on the original graph
            for neighbor in G.neighbors((y, x)):
                if G_copy.has_node(neighbor):
                    G_copy.add_edge((y, x), neighbor)

    return count


if __name__ == "__main__":
    dat = get_data(day=6, year=2024).split("\n")

    G, start_pos, start_dir = build_graph(dat)

    sim_result = sim_guard_move(G, dat, start_pos, start_dir)

    part1 = len(sim_result[0])

    part2 = find_loops(dat)

    print(f"Part1: {part1}\nPart2: {part2}")

    # submit(part2, part="b", day=6, year=2024)
