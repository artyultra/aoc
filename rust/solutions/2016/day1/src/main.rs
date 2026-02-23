mod common;
mod part1;

use common::Op;
use std::fs;

fn parse_ops(input: &str) -> Vec<Op> {
    let data = fs::read_to_string(input).unwrap();
    data.split(',')
        .map(|s| {
            let clean = s.trim();
            let turn = clean.chars().nth(0).unwrap();
            let dist: i32 = clean[1..].parse().unwrap();
            Op { turn, dist }
        })
        .collect()
}

fn main() {
    let ops = parse_ops("input.txt");

    let part_one_res = part1::solve(&ops);
    println!("Result: {}", part_one_res);

    let part_two_res = part1::solve_part_two(&ops);
    println!("Result: {}", part_two_res);
}
