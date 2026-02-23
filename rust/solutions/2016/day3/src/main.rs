use std::fs;

mod types;

use types::{parse_triangle_p1, parse_triangle_p2};

fn main() {
    let data = fs::read_to_string("input.txt").unwrap();
    println!("Part 1: {}", solve_part1(&data));
    println!("Part 2: {}", solve_part2(&data));
}

fn solve_part1(data: &str) -> usize {
    let mut count: usize = 0;
    let triangles = parse_triangle_p1(&data);
    for triangle in &triangles {
        if triangle.is_valid() {
            count += 1;
        }
    }
    count
}

fn solve_part2(data: &str) -> usize {
    let mut count: usize = 0;
    let triangles = parse_triangle_p2(&data);
    for triangle in &triangles {
        if triangle.is_valid() {
            count += 1;
        }
    }
    count
}
