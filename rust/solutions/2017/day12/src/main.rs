mod parser;

use parser::parse_pipes_map;
use std::collections::{HashMap, HashSet};
use std::fs;

type Pipes = HashMap<u32, Vec<u32>>;

fn find_group(pipes: &Pipes, start: u32) -> HashSet<u32> {
    let mut visited = HashSet::new();
    let mut stack = vec![start];
    while let Some(node) = stack.pop() {
        if visited.insert(node) {
            if let Some(neighbors) = pipes.get(&node) {
                for n in neighbors {
                    if !visited.contains(n) {
                        stack.push(*n);
                    }
                }
            }
        }
    }
    visited
}

fn count_groups(pipes: &Pipes) -> u32 {
    let mut visited: HashSet<u32> = HashSet::new();
    let mut groups = 0;
    for &node in pipes.keys() {
        if !visited.contains(&node) {
            let group = find_group(pipes, node);
            visited.extend(group);
            groups += 1;
        }
    }
    groups
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let pipe_map = parse_pipes_map(&input);
    println!("Part 1: {}", find_group(&pipe_map, 0).len());
    println!("Part 2: {}", count_groups(&pipe_map));
}
