#!/opt/homebrew/bin/bash

WORKDIR="$HOME/dev/aoc/rust"

source "$WORKDIR/.env"

YEAR=$1
DAY=$2

base_url="https://adventofcode.com"

puzzle_dat=$(
  curl -s "$base_url/$YEAR/day/$DAY/input" \
    --cookie "session=$AOC_SESSION"
)

FOLDER_PATH="$WORKDIR/solutions/$YEAR/day$DAY"

## init new rust project
cargo init "$FOLDER_PATH"

touch "$FOLDER_PATH/input.txt"
echo "$puzzle_dat" >"$FOLDER_PATH/input.txt"

cd "$FOLDER_PATH"
cargo run
