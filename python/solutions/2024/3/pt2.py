import sys
import re

if len(sys.argv) > 1:
    file_inp = sys.argv[1]
else:
    raise Exception("please provide a filename")

with open(file_inp, 'r') as file:
    content = file.read()

matches = re.findall(r'(?:do\(\)|don\'t\(\)|mul\([0-9]+,[0-9]+\))', content)

sum = 0
enabled = True
for match in matches:
    if "don't" in match:
        enabled = False
        continue
    if "do" in match:
        enabled = True
        continue
    if enabled:
        nums = re.findall(r'[0-9]+', match)
        sum += int(nums[0]) * int(nums[1])

print(sum)
