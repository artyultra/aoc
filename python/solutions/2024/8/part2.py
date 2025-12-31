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
    antennas = {}
    for y, row in enumerate(dat):
        for x, cell in enumerate(row):
            if cell != ".":
                if cell not in antennas:
                    antennas[cell] = 1
                antennas[cell] += 1
                G.add_node((y, x), cell=cell)

    return G, antennas


def get_antinodes(first, second, dat):
    col_len = len(dat)
    row_len = len(dat[0])

    def check_back(coord):
        if (0, 0) <= coord < (col_len, row_len):
            return True
        else:
            return False

    def check_front(coord):
        if (0, 0) <= coord < (col_len, row_len):
            return True
        else:
            return False

    found = set()
    found.add(first)
    found.add(second)
    y1, x1 = first
    y2, x2 = second
    dy, dx = y2 - y1, x2 - x1
    valid = True
    while valid:
        back = (y1 - dy, x1 - dx)
        front = (y2 + dy, x2 + dx)
        if check_back(back) or check_front(front):
            if check_back(back):
                found.add(back)
            if check_front(front):
                found.add(front)
            dy += y2 - y1
            dx += x2 - x1
        else:
            valid = False

    return found


def list_antinodes(G, dat):
    col_len = len(dat)
    row_len = len(dat[0])

    antinodes = set()
    # Iterate over unique pairs of nodes
    for (node, data), (node_, data_) in combinations(G.nodes(data=True), 2):
        cell, cell_ = data["cell"], data_["cell"]
        if cell == cell_:  # Same frequency
            y, x = node
            y_, x_ = node_
            for antinode in get_antinodes((y, x), (y_, x_), dat):
                ay, ax = antinode
                if 0 <= ay < col_len and 0 <= ax < row_len:  # Bounds check
                    if antinode not in antinodes:
                        antinodes.add(antinode)

    return antinodes


if __name__ == "__main__":
    raw_dat = get_data(day=8, year=2024).split("\n")

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
............""".split()

    dat = []
    # for row in sample_dat:
    for row in raw_dat:
        dat.append(list(row))

    G, antennas = build_graph(dat)
    antinodes = list_antinodes(G, dat)

    print(len(antinodes))

    # print(f"part1: {antinodes}")

    submit(f"{len(antinodes)}", part="b", day=8, year=2024)
