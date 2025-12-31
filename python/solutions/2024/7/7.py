from aocd import get_data, submit
import re
from itertools import product

"""
TO SEE RESULT OF PART 1

remove "||" from operators tuple (line: 21)
comment out lines "31, 32"
"""


def build_equation(raw_dat):
    raw_dat_ = raw_dat.split("\n")
    equations = []
    for line in raw_dat_:
        result, numbers = line.split(":")
        equation_nums = list(map(int, re.findall(r"[0-9]+", numbers)))
        equations.append((int(result), equation_nums))
    return equations


def can_solve(eq):
    result, numbers = eq
    operators = ("+", "*", "||")
    num_operators = len(numbers) - 1
    operator_combinations = list(product(operators, repeat=num_operators))
    for i, combo in enumerate(operator_combinations, 1):
        total = numbers[0]
        for i, op in enumerate(combo):
            nums = numbers[1:]
            if op == "+":
                total += nums[i]
            elif op == "||":
                total = int(str(total) + str(nums[i]))
            else:
                total *= nums[i]
        if result == total:
            return True
    return False


if __name__ == "__main__":
    sample_dat = """190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20"""
    raw_dat = get_data(day=7, year=2024)
    equations = build_equation(raw_dat)
    total = 0
    for result, numbers in equations:
        eq = (result, numbers)
        if can_solve(eq):
            total += result

    submit(str(total), part="b", day=7, year=2024)
