#!/opt/homebrew/bin/bash

source "$HOME/aoc/bash/.env"

INPUT="$PWD/input.txt"
EXAMPLE="$PWD/example.txt"

# input=$(cat "$INPUT_PATH")

mapfile -t input < <(cat "$INPUT")

total=0
for line in "${input[@]}"; do
  length=${#line}
  tens=0
  ones=0
  for ((i = 0; i < length - 1; i++)); do
    num=${line:$i:1}
    num2=${line:$((i + 1)):1}
    if ((num > tens)); then
      tens="$num"
      ones="$num2"
    fi
    if ((num2 > ones)); then
      ones=$num2
    fi
  done
  final="$tens$ones"
  total=$((total + final))
done
echo "$total"
