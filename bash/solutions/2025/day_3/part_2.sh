#!/opt/homebrew/bin/bash

source "$HOME/dev/aoc/bash/.env"

INPUT_PATH="$PWD/$1"

mapfile -t input < <(cat "$INPUT_PATH")

digits=12
for line in "${input[@]}"; do
  num=""
  start=0
  length=${#line}
  for ((d = 0; d < digits; d++)); do
    best_val=0
    best_pos=$start
    remaining=$((digits - d - 1))
    for ((i = start; i <= length - remaining - 1; i++)); do
      char="${line:$i:1}"
      if ((char > best_val)); then
        best_val=$char
        best_pos=$i
      fi
    done
    num="${num}${best_val}"
    start=$((best_pos + 1))
  done
  total=$((total + num))
done
echo "part2: $total"
