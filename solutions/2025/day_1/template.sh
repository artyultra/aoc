#!/opt/homebrew/bin/bash

source "$HOME/aoc/bash/solutions/2025/day_1/helpers.sh"

INPUT_PATH="/Users/kiga/aoc/bash/solutions/2025/day_1/input.txt"
EXAMPLE_PATH="/Users/kiga/aoc/bash/solutions/2025/day_1/example.txt"
mapfile -t DATA < \
  "$INPUT_PATH"

CURRENT="50"
SUM=0

for I in "${!DATA[@]}"; do
  LINE="${DATA[$I]}"
  ROTATION="${LINE:0:1}"
  CLICKS="${LINE:1}"

  ZEROS=$(count_zeros "$ROTATION" "$CURRENT" "$CLICKS")
  SUM=$((SUM + ZEROS))

  RESULT=$(result "$ROTATION" "$CURRENT" "$CLICKS")
  FINAL=$(final_result "$RESULT")
  # echo "#$I: $CURRENT:$LINE:$FINAL -> $ZEROS"
  CURRENT="$FINAL"
done

echo "$SUM"
