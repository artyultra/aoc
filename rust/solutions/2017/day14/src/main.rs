mod knot_hash;

use knot_hash::knot_hash;

use std::fs;

use std::collections::HashSet;

fn part_one(input: &str) -> u32 {
    let mut sum = 0;
    for i in 0..128 {
        let key = format!("{}-{}", input, i);
        let hash = knot_hash(&key);
        let ones: u32 = hash
            .chars()
            .map(|c| c.to_digit(16).unwrap().count_ones())
            .sum();
        sum += ones;
    }
    sum
}

fn get_graph(input: &str) -> Vec<Vec<bool>> {
    let mut graph: Vec<Vec<bool>> = Vec::new();
    for i in 0..128 {
        let key = format!("{}-{}", input, i);
        let hash = knot_hash(&key);
        let binary_repr: Vec<bool> = hash
            .chars()
            .flat_map(|c| {
                let val = c.to_digit(16).unwrap();
                (0..4).rev().map(move |i| (val >> i) & 1 == 1)
            })
            .collect();
        graph.push(binary_repr);
    }
    graph
}

fn traverse_graph(
    graph: &Vec<Vec<bool>>,
    group: &mut Vec<(usize, usize)>,
    visited: &mut HashSet<(usize, usize)>,
    start: (usize, usize),
) {
    if visited.contains(&start) || !graph[start.0][start.1] {
        return;
    } else {
        visited.insert(start);
    }
    group.push(start);
    let dirs: Vec<(i32, i32)> = vec![(0, 1), (0, -1), (1, 0), (-1, 0)];
    for dir in dirs {
        let next = ((start.0 as i32 + dir.0), (start.1 as i32 + dir.1));
        if next.0 < 0
            || next.0 >= graph.len() as i32
            || next.1 < 0
            || next.1 >= graph[0].len() as i32
        {
            continue;
        }
        traverse_graph(graph, group, visited, (next.0 as usize, next.1 as usize));
    }
}

fn part_two(graph: &Vec<Vec<bool>>) -> u32 {
    let mut visited: HashSet<(usize, usize)> = HashSet::new();
    let mut groups: u32 = 0;
    for i in 0..graph.len() {
        for j in 0..graph[0].len() {
            let start = (i, j);
            if visited.contains(&start) {
                continue;
            }
            let mut group: Vec<(usize, usize)> = Vec::new();
            traverse_graph(graph, &mut group, &mut visited, start);
            if group.len() > 0 {
                groups += 1;
            }
        }
    }
    groups
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    println!("{}", part_one(&input));
    let p2 = part_two(&get_graph(&input));
    println!("{}", p2);
}
