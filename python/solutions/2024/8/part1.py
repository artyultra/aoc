from aocd import get_data, submit
import networkx as nx
import re
from itertools import combinations


def build_graph(dat):
    """
    dat is a list of lines containing "." and various [a-zA-Z] [0-9] chars

    build graph will create a graph based on x, y coordinates

    """
    # Empty undirected Graph
    G = nx.Graph()
    antennas = set()
    for y, row in enumerate(dat):
        for x, cell in enumerate(row):
            if cell != ".":
                G.add_node((y, x), cell=cell)
                antennas.add(cell)

    return G, antennas


def get_antinodes(first, second):
    found = set()
    y1, x1 = first
    y2, x2 = second
    dy, dx = y2 - y1, x2 - x1
    back = (y1 - dy, x1 - dx)
    front = (y2 + dy, x2 + dx)
    found.add(back)
    found.add(front)
    return found


def list_antinodes(G, dat):
    col_len = len(dat)
    row_len = len(dat[0])
    print(col_len)
    print(row_len)

    antinodes = set()
    # Iterate over unique pairs of nodes
    for (node, data), (node_, data_) in combinations(G.nodes(data=True), 2):
        cell, cell_ = data["cell"], data_["cell"]
        if cell == cell_:  # Same frequency
            y, x = node
            y_, x_ = node_
            for antinode in get_antinodes((y, x), (y_, x_)):
                ay, ax = antinode
                if 0 <= ay < col_len and 0 <= ax < row_len:  # Bounds check
                    if antinode not in antinodes:
                        antinodes.add(antinode)

    return antinodes


if __name__ == "__main__":
    sample_dat = """............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""
    raw_dat = get_data(day=8, year=2024).split("\n")
    dat = []
    for row in raw_dat:
        dat.append(list(row))

    G, antennas = build_graph(dat)
    antinodes = list_antinodes(G, dat)
    print(f"part1: {antinodes}")

    submit(f"{len(antinodes)}", part="a", day=8, year=2024)
