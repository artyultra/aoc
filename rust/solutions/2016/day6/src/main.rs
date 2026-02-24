mod parser;

use parser::parse_input_lines;
use std::collections::HashMap;

fn main() {
    let lines = parse_input_lines("input.txt");
    let message_p1 = solve_part_one(&lines);
    println!("Part 1: {}", message_p1);
    let message_p2 = solve_part_two(&lines);
    println!("Part 2: {}", message_p2);
}

fn solve_part_one(lines: &Vec<String>) -> String {
    let mut message = String::new();
    let line_length = lines[0].len();
    let mut idx = 0;
    while idx < line_length {
        let mut map: HashMap<char, usize> = HashMap::new();
        for line in lines {
            let c = line.chars().nth(idx).unwrap();
            *map.entry(c).or_insert(0) += 1;
        }
        let max_char = map.iter().max_by_key(|&(_, count)| count).unwrap().0;
        message.push(*max_char);
        idx += 1;
    }
    message
}
fn solve_part_two(lines: &Vec<String>) -> String {
    let mut message = String::new();
    let line_length = lines[0].len();
    let mut idx = 0;
    while idx < line_length {
        let mut map: HashMap<char, usize> = HashMap::new();
        for line in lines {
            let c = line.chars().nth(idx).unwrap();
            *map.entry(c).or_insert(0) += 1;
        }
        let max_char = map.iter().min_by_key(|&(_, count)| count).unwrap().0;
        message.push(*max_char);
        idx += 1;
    }
    message
}
