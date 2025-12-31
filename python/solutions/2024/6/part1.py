from aocd import get_data, submit
import networkx as nx


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


def sim_gaurd_move(G, dat, start_pos, start_dir):
    """
    Simulates the guard's movement based on the patrol protocol.
    Returns a set of visited positions.
    """
    visited = set()
    current_pos = start_pos
    current_dir = start_dir
    visited.add(current_pos)

    # initialize directions:
    dir_vectors = {"up": (-1, 0), "right": (0, 1), "down": (1, 0), "left": (0, -1)}

    # define turning right
    right_turn = {"up": "right", "right": "down", "down": "left", "left": "up"}

    while True:
        dy, dx = dir_vectors[current_dir]
        next_pos = (current_pos[0] + dy, current_pos[1] + dx)

        y, x = next_pos

        # Check if next_pos is within the map boundaries
        if 0 <= y < len(dat) and 0 <= x < len(dat[y]):
            cell = dat[y][x]
            if cell != "#":
                # Passable: Move forward
                current_pos = next_pos
                visited.add(current_pos)
            else:
                # Obstacle: Turn right
                current_dir = right_turn[current_dir]
        else:
            # Out of bounds: Guard leaves the map
            break

    return visited


if __name__ == "__main__":
    dat = get_data(day=6, year=2024).split("\n")

    G, start_pos, start_dir = build_graph(dat)

    visited = sim_gaurd_move(G, dat, start_pos, start_dir)

    print(len(visited))

    submit(len(visited), part="a", day=6, year=2024)
