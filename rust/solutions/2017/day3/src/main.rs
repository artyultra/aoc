mod part_one;
use part_one::solve_part1;
use std::fs;
mod part_two;
use part_two::solve_part2;

fn main() {
    let data: u32 = fs::read_to_string("input.txt")
        .unwrap()
        .trim()
        .parse()
        .unwrap();
    println!("Part 1: {}", solve_part1(&data));
    println!("Part 2: {}", solve_part2(data));
}
