mod parser;
use parser::{parse_addr, parse_lines};

fn find_abba(seq: &str) -> bool {
    let chars: Vec<char> = seq.chars().collect();
    for i in 0..chars.len() - 3 {
        if chars[i] == chars[i + 3] && chars[i + 1] == chars[i + 2] && chars[i] != chars[i + 1] {
            return true;
        }
    }
    false
}

fn aba_to_bab(aba: &str) -> String {
    let chars: Vec<char> = aba.chars().collect();
    format!("{}{}{}", chars[1], chars[0], chars[1])
}

fn find_aba(seq: &str) -> Option<Vec<String>> {
    let mut abas: Vec<String> = Vec::new();
    let chars: Vec<char> = seq.chars().collect();
    for i in 0..chars.len() - 2 {
        if chars[i] == chars[i + 2] && chars[i] != chars[i + 1] {
            abas.push(seq[i..i + 3].to_string());
        }
    }
    if abas.len() > 0 {
        return Some(abas);
    }
    None
}

#[allow(dead_code)]
fn solve_part_one(lines: &Vec<String>) -> i32 {
    let mut count: i32 = 0;

    for line in lines {
        let addr = parse_addr(&line);

        let has_inner = addr.inners.iter().any(|s| find_abba(s));
        let has_outter = addr.outers.iter().any(|s| find_abba(s));

        if has_outter && !has_inner {
            count += 1;
        }
    }
    count
}

fn solve_part_two(lines: &Vec<String>) -> i32 {
    let mut count: i32 = 0;
    for line in lines {
        let addr = parse_addr(&line);
        let abas: Vec<String> = addr
            .outers
            .iter()
            .flat_map(|s| find_aba(s).unwrap_or_default())
            .collect();

        let found = abas.iter().any(|aba| {
            let bab = aba_to_bab(aba);
            addr.inners.iter().any(|inner| inner.contains(&bab))
        });
        if found {
            count += 1;
        }
    }
    count
}

fn main() {
    let lines = parse_lines("input.txt");
    // println!("Part 1: {}", solve_part_one(&lines));
    println!("Part 2: {}", solve_part_two(&lines));
}
