import sys

def is_sequential(list):
    if len(list) <= 1:
        return True
    
    ascending = all(list[i] <= list[i + 1] for i in range(len(list) - 1))
    descending = all(list[i] >= list[i + 1] for i in range(len(list) - 1))

    return ascending or descending

def is_safe_diff(list):
    diff = all(1 <= abs(list[i] - list[i + 1]) <= 3 for i in range(len(list) - 1))
    return diff


if len(sys.argv) > 1:
    file_inp = sys.argv[1]
else:
    raise Exception("please provide a filename")

reports = []
with open(file_inp, 'r') as file:
    for line in file:
        add_report = line.strip().split()
        integers = [int(x) for x in add_report]
        reports.append(integers)

count = 0
for report in reports:
    if is_sequential(report) and is_safe_diff(report):
        count += 1

print(count)
