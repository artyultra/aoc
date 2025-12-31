#!/opt/homebrew/bin/bash

function result() {
  ROTATION="$1"
  START="$2"
  CLICKS="$3"
  case "$ROTATION" in
    "L")
      echo $((START - CLICKS))
      ;;
    "R")
      echo $((START + CLICKS))
      ;;
    *)
      echo "Invalid rotation"
      exit 1
      ;;
  esac
}

function final_result() {
  local result="$1"
  echo $(((result % 100 + 100) % 100))
}

function count_zeros() {
  local rotation="$1"
  local start="$2"
  local clicks="$3"
  case "$rotation" in
    "L")
      echo $(check_left "$start" "$clicks")
      ;;
    "R")
      echo $(check_right "$start" "$clicks")
      ;;
    *)
      echo "Invalid rotation"
      exit 1
      ;;
  esac
}

function check_right() {
  local start="$1"
  local clicks="$2"
  local dist_to_zero=$((100 - start))

  if ((start == 0)); then
    echo $((clicks / 100))
  elif ((clicks < dist_to_zero)); then
    echo "0"
  else
    echo $(((clicks - dist_to_zero) / 100 + 1))
  fi
}

function check_left() {
  local start="$1"
  local clicks="$2"

  if ((start == 0)); then
    echo $((clicks / 100))
  elif ((clicks < start)); then
    echo "0"
  else
    echo $(((clicks - start) / 100 + 1))
  fi
}
