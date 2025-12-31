#!/opt/homebrew/bin/bash

is_invalid() {
  local num=$1
  local len=${#num}

  if ((len % 2 != 0)); then
    return 1 # Not invalid
  fi

  local half=$((len / 2))
  local first_half=${num:0:half}
  local second_half=${num:half:half}

  if [[ "$first_half" == "$second_half" ]]; then
    return 0 # Invalid!
  else
    return 1 # Valid
  fi
}

is_invalid_part2() {
  local num=$1
  local num_len=${#num}
  local half=$((num_len / 2))

  for ((i = 1; i <= half; i++)); do
    if ((num_len % i != 0)); then
      continue
    fi
    pattern=${num:0:i}
    matches=true

    for ((pos = 0; pos < num_len; pos += i)); do
      if [[ "${num:pos:i}" != "$pattern" ]]; then
        matches=false
        break
      fi
    done

    if $matches; then
      return 0 # Invalid
    fi
  done
  return 1 # Valid
}

efficiency_test() {
  local num=$1
  local num_len=${#num}

  # Only check divisors of the length (optimization)
  for ((i = 1; i <= num_len / 2; i++)); do
    # Skip if i doesn't divide evenly into num_len
    if ((num_len % i != 0)); then
      continue
    fi

    local pattern="${num:0:i}"
    local matches=true

    # Check if pattern repeats throughout the number
    for ((pos = 0; pos < num_len; pos += i)); do
      if [[ "${num:pos:i}" != "$pattern" ]]; then
        matches=false
        break
      fi
    done

    if $matches; then
      return 0 # Invalid (found repeating pattern)
    fi
  done

  return 1 # Valid
}
