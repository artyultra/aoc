mod parser;

use parser::parse_input;

fn solve_part_one(data: &str) -> usize {
    let mut length: usize = 0;
    let mut i: usize = 0;
    while i < data.len() {
        let c = data.as_bytes()[i] as char;
        match c {
            '(' => {
                let mut end = i + 1;
                while data.as_bytes()[end] as char != ')' {
                    end += 1;
                }
                let marker = &data[i + 1..end];
                let mut parts = marker.split('x');
                let range: usize = parts.next().unwrap().parse().unwrap();
                let mult: usize = parts.next().unwrap().parse().unwrap();
                length += range * mult;
                i = end + 1 + range;
            }
            _ => {
                length += 1;
                i += 1;
            }
        }
    }
    length
}
fn solve_part_two(data: &str) -> usize {
    let mut length: usize = 0;
    let mut i: usize = 0;
    while i < data.len() {
        let c = data.as_bytes()[i] as char;
        match c {
            '(' => {
                let mut end = i + 1;
                while data.as_bytes()[end] as char != ')' {
                    end += 1;
                }
                let marker = &data[i + 1..end];
                let mut parts = marker.split('x');
                let range: usize = parts.next().unwrap().parse().unwrap();
                let mult: usize = parts.next().unwrap().parse().unwrap();

                let section = &data[end + 1..end + 1 + range];
                length += solve_part_two(section) * mult;
                i = end + 1 + range;
            }
            _ => {
                length += 1;
                i += 1;
            }
        }
    }
    length
}

fn main() {
    let data = parse_input("input.txt");
    println!("Part 1: {}", solve_part_one(&data));
    println!("Part 2: {}", solve_part_two(&data));
}
