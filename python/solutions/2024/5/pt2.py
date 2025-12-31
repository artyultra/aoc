import sys
import re
from collections import defaultdict, deque


def split_data(data_list):
    rules = []
    pages = []
    for i in range(len(data_list)):

        # HANDLE RULE LINES
        if "|" in data_list[i]:
            r1, r2 = map(int, re.findall(r"[0-9]+", data_list[i]))
            rules.append([r1, r2])
            continue

        # HANDLE EMPTY LINES
        if data_list[i] == "":
            continue

        # HANDLE PAGE LINES
        page = list(map(int, re.findall(r"[0-9]+", data_list[i])))
        pages.append(page)

    return rules, pages


def build_global_graph(rules):
    """
    rules: list of [r1, r2] meaning r1 must come before r2
    return dict (adjacency list) { page: [list of pages that come after]}
    """
    graph = defaultdict(list)
    for x, y in rules:
        graph[x].append(y)
        # insure y in graph even if no edges
        if y not in graph:
            graph[y] = []
    return graph


def is_correct(update_pages, global_graph):
    """
    update_pages: list of integers (the update order as given)
    global_graph: adjacency list for all rules
    return: True if `update_pages` respects all relevant ordering constraints
    """

    # Build a quick lookup: page --> index in 'update_pages'
    index_map = {}
    for i, page in enumerate(update_pages):
        index_map[page] = i

    for page in update_pages:
        for neighbor in global_graph[page]:
            if neighbor in index_map:
                if index_map[page] > index_map[neighbor]:

                    return False
    return True


def build_subgraph(update_pages, global_graph):
    """
    update_pages: a list of page numbers
    global_graph: list of pages, and their adjacencies
    return adjacenc list containing only edges among update_pages
    """
    update_set = set(update_pages)
    subgraph = {}

    # init subgraph keys
    for p in update_pages:
        subgraph[p] = []

    # For each page in the update, see which neighbors are in the list
    for p in update_pages:
        for neighbor in global_graph[p]:
            if neighbor in update_set:
                subgraph[p].append(neighbor)
    return subgraph


def topo_sort_kahn(subgraph):
    in_degrees = {node: 0 for node in subgraph}
    for u in subgraph:
        for v in subgraph[u]:
            in_degrees[v] += 1

    queue = deque([u for u in subgraph if in_degrees[u] == 0])
    topo_order = []

    while queue:
        u = queue.popleft()
        topo_order.append(u)

        for v in subgraph[u]:
            in_degrees[v] -= 1
            if in_degrees[v] == 0:
                queue.append(v)

    if len(topo_order) < (len(subgraph)):
        raise Exception("Ordering not possible")

    return topo_order


# Read input
if len(sys.argv) < 2:
    raise Exception("please provide a filename")

with open(sys.argv[1], "r") as file:
    rawdata_lst = [line.strip() for line in file]


def main():
    # Parses input
    rules_raw, pages_raw = split_data(rawdata_lst)
    """
    rules_raw = list of rules
    pages_raw = list of list of page numbers
    """

    # Build glabal adjacency list
    global_graph = build_global_graph(rules_raw)

    # track both some of middle integers
    correct = 0
    incorrect = 0

    # check each update, see if its in the correct order
    for update in pages_raw:
        if is_correct(update, global_graph):
            middle_idx = len(update) // 2
            correct += update[middle_idx]
        else:
            subgraph = build_subgraph(update, global_graph)
            corrected_order = topo_sort_kahn(subgraph)

            mid_idx = len(corrected_order) // 2
            incorrect += corrected_order[mid_idx]

    print(f"Correct: {correct}\nIncorrect: {incorrect}")


main()
