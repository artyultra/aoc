#!/opt/homebrew/bin/bash

# This script will setup the environment for the bash solutions

working_dir="$HOME/aoc/zig"

source "$working_dir/.env"

YEAR="$1"
DAY="$2"

base_url="https://adventofcode.com"

puzzle_dat=$(
  curl -s "$base_url/$YEAR/day/$DAY/input" \
    --cookie "session=$AOC_SESSION"
)

FOLDER_PATH="$working_dir/solutions/$YEAR/day_$DAY"
mkdir -p "$FOLDER_PATH" \
  && touch "$FOLDER_PATH/input.txt" \
  && touch "$FOLDER_PATH/example.txt"

cd "$working_dir/solutions/$YEAR/day_$DAY"

# init zig project
zig init -n day$DAY

echo "$puzzle_dat" > \
  "$FOLDER_PATH/input.txt"

TEMPLATE_TEXT="#!/opt/homebrew/bin/bash

source \"\$HOME/aoc/bash/.env\"

INPUT_PATH=\"\$PWD/input.txt\"
EXAMPLE_PATH=\"\$PWD/example.txt\"

input=\$(cat \"\$INPUT_PATH\")

echo \"$input\"
"

echo "$TEMPLATE_TEXT" > \
  "$FOLDER_PATH/part_1.sh"
echo "$TEMPLATE_TEXT" > \
  "$FOLDER_PATH/part_2.sh"
