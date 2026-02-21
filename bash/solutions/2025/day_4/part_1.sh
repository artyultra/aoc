#!/opt/homebrew/bin/bash

source "$HOME/dev/aoc/bash/.env"

INPUT_PATH="$PWD/input.txt"
EXAMPLE_PATH="$PWD/example.txt"

mapfile -t input < <(cat "$INPUT_PATH")

grid=$(cat "$INPUT_PATH" | tr -d '\n')
cols=${#input[0]} # width of a row
rows=${#input[@]} # number of rows

flattened_idx() {
  local -n ref=$3
  x=$1
  y=$2
  ref=$((y * cols + x))
}

get_coords() {
  local -n ref=$2
  idx=$1
  x=$((idx % cols))
  y=$((idx / cols))
  ref="$x,$y"
}

check_neighbors() {
  local -n ref=$2
  idx=$1
  get_coords $idx coords
  sx=${coords%,*}
  sy=${coords#*,}

  dirs=(-1,-1 0,-1 1,-1 -1,0 1,0 -1,1 0,1 1,1)
  ref=0
  for d in "${dirs[@]}"; do
    dx=${d%,*}
    dy=${d#*,}
    nx=$((sx + dx))
    ny=$((sy + dy))
    if ((nx < 0 || nx >= cols || ny < 0 || ny >= rows)); then
      continue
    fi
    flattened_idx $nx $ny f_idx
    cell=${grid:$f_idx:1}
    if [[ $cell == "@" ]]; then
      ref=$((ref + 1))
    fi
  done
}

for ((i = 0; i < ${#grid}; i++)); do
  if [[ ${grid:$i:1} == "@" ]]; then
    check_neighbors $i num_rolls
    if ((num_rolls < 4)); then
      total=$((total + 1))
    fi
  fi
done

echo "part1: $total"
