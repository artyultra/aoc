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

frequency = {}

for num1 in sorted_id1:
    count = 0
    if num1 not in sorted_id2:
        frequency[num1] = 0
        pass
    for num2 in sorted_id2:
        if num1 == num2:
            frequency[num1] = count + 1
            count += 1
sum = 0
for n in sorted_id1:
    num = frequency[n] 
    sum += n * num

print(sum)
