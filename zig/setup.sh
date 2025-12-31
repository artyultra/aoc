#!/opt/homebrew/bin/bash

# This script will setup the environment for the bash solutions

working_dir="$HOME/dev/aoc/zig"

source "$working_dir/.env"

YEAR="$1"
DAY="$2"

base_url="https://adventofcode.com"

puzzle_dat=$(
  curl -s "$base_url/$YEAR/day/$DAY/input" \
    --cookie "session=$AOC_SESSION"
)

FOLDER_PATH="$working_dir/solutions/$YEAR/day$DAY"
mkdir -p "$FOLDER_PATH" \
  && mkdir -p "$FOLDER_PATH/src" \
  && touch "$FOLDER_PATH/src/main.zig" \
  && touch "$FOLDER_PATH/build.zig" \
  && touch "$FOLDER_PATH/input.txt" \
  && touch "$FOLDER_PATH/example.txt"

cd "$working_dir/solutions/$YEAR/day$DAY"

echo "$puzzle_dat" > \
  "$FOLDER_PATH/input.txt"

cp "$working_dir/templates/main.zig" \
  "$FOLDER_PATH/src/main.zig"

cp "$working_dir/templates/build.zig" \
  "$FOLDER_PATH/build.zig"

sed -i '' "s/myproject/DAY$DAY/" "$FOLDER_PATH/build.zig"

cd "$working_dir/solutions/$YEAR/day$DAY/"

zig build run
