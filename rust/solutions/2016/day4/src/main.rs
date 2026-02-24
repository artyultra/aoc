mod parser;

use std::collections::HashMap;

use parser::{parse_input_lines, parse_line};

fn build_checksum(name: &str) -> String {
    let mut map: HashMap<char, i32> = HashMap::new();
    for c in name.chars() {
        if c == '-' {
            continue;
        }
        *map.entry(c).or_insert(0) += 1;
    }

    let mut sorted: Vec<(char, i32)> = map.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));

    sorted.iter().map(|(c, _)| c).take(5).collect()
}

fn shift_char(c: &char, id: i32) -> char {
    let base = *c as u32 - 'a' as u32;
    let rotated = (base + id as u32) % 26;
    (rotated + 'a' as u32) as u8 as char
}

fn is_valid_room(line: &str) -> bool {
    let (name, _, checksum) = parse_line(line);
    build_checksum(&name) == checksum
}

fn solve_part_one(lines: &Vec<String>) -> i32 {
    let mut sum = 0;
    for line in lines {
        if is_valid_room(line) {
            let (_, id, _) = parse_line(line);
            sum += id;
        }
    }
    sum
}

fn solve_part_two(lines: &Vec<String>) -> i32 {
    for line in lines {
        if !is_valid_room(line) {
            continue;
        }
        let (name, id, _) = parse_line(line);
        let decrypted: String = name
            .chars()
            .map(|c| if c == '-' { ' ' } else { shift_char(&c, id) })
            .collect();
        if decrypted.contains("northpole") {
            return id;
        }
    }
    0
}

fn main() {
    let lines = parse_input_lines("input.txt");
    println!("Part 1: {}", solve_part_one(&lines));
    println!("Part 2: {}", solve_part_two(&lines));
}
