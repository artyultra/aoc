#!/opt/homebrew/bin/bash

source "$HOME/dev/aoc/bash/.env"

INPUT_PATH="$PWD/$1"

mapfile -t input < <(cat "$INPUT_PATH")

for line in "${input[@]}"; do
  best=0
  length=${#line}
  for ((i = 0; i < length; i++)); do
    for ((j = i + 1; j < length; j++)); do
      num="${line:$i:1}${line:$j:1}"
      if ((num > best)); then
        best=$num
      fi
    done
  done
  total=$((total + best))
done
echo "part2: $total"
