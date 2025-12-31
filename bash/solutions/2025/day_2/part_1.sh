#!/opt/homebrew/bin/bash

source "$PWD/helpers.sh"

INPUT_PATH="$PWD/input.txt"
EXAMPLE_PATH="$PWD/example.txt"

input=$(cat "$INPUT_PATH")

input=${input//[$'\n\r ']/}

IFS="," read -ra ranges <<<"$input"

total=0

for range in "${ranges[@]}"; do
  start=${range%%-*}
  end=${range##*-}

  for ((num = start; num <= end; num++)); do
    if is_invalid "$num"; then
      total=$((total + num))
    fi
  done
done

echo "total: $total"
