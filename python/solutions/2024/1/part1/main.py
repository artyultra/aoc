import sys

if len(sys.argv) > 1:
    file_inp = sys.argv[1]
else:
    raise Exception("please provide a filename")

id1 = []
id2 = []

with open(file_inp, 'r') as file:
    for line in file:
        first, second = line.strip().split()
        id1.append(int(first))
        id2.append(int(second))

sorted_id1 = sorted(id1)
sorted_id2 = sorted(id2)

diff_list = []

for i in range(0, len(sorted_id1)):
    diff_list.append(sorted_id1[i] - sorted_id2[i])

sum = 0
for num in diff_list:
    sum += abs(num)

print(sum)
