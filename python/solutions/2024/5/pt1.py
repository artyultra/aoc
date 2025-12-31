import sys
import re


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


def check_pages(rules, pages):
    correct_pages = []
    for page in pages:
        correct = True
        for rule in rules:
            if rule[0] not in page or rule[1] not in page:
                continue
            r1_pos = page.index(rule[0])
            r2_pos = page.index(rule[1])
            if r1_pos < r2_pos:
                continue
            else:
                correct = False
                break
        if correct:
            correct_pages.append(page)

    return correct_pages


def get_middle(lst):
    median = int((len(lst) / 2) - 0.5)
    return lst[median]


# Read input
if len(sys.argv) < 2:
    raise Exception("please provide a filename")

with open(sys.argv[1], "r") as file:
    rawdata_lst = [line.strip() for line in file]


def main():
    rules_raw, pages_raw = split_data(rawdata_lst)
    passing_pages = check_pages(rules_raw, pages_raw)
    count = 0
    for page in passing_pages:
        count += get_middle(page)
    print(count)


main()
