mod parser;

use std::{collections::HashMap, fs};

use crate::parser::{parse, Program};

type Programs = HashMap<String, Program>;

fn solve_part_one(programs: &Programs) -> Option<String> {
    'outer: for (name, _) in programs {
        for (_, program2) in programs {
            if program2.children.contains(name) {
                continue 'outer;
            }
        }
        return Some(name.to_string());
    }
    None
}

fn get_total_weight(programs: &Programs, name: &str) -> u32 {
    let program = programs.get(name).unwrap();
    program.weight
        + program
            .children
            .iter()
            .map(|s| get_total_weight(programs, s))
            .sum::<u32>()
}

fn solve_part_two(programs: &Programs, name: &str) -> u32 {
    let node = programs.get(name).unwrap();
    if node.children.is_empty() {
        panic!("reached a leaf - this should not happen");
    }

    let weights: Vec<u32> = node
        .children
        .iter()
        .map(|child| get_total_weight(programs, child))
        .collect();

    let majority = if weights[0] == weights[1] {
        weights[0]
    } else {
        weights[2]
    };

    let (idx, odd) = weights
        .iter()
        .enumerate()
        .find(|(_, w)| **w != majority)
        .unwrap();

    let bad_child_name = &node.children[idx];
    let bad_child = programs.get(bad_child_name).unwrap();

    // check if the imbalance is deeper
    if !bad_child.children.is_empty() {
        let child_weights: Vec<u32> = bad_child
            .children
            .iter()
            .map(|child| get_total_weight(programs, child))
            .collect();

        let all_equal = child_weights.iter().all(|w| *w == child_weights[0]);
        if !all_equal {
            // problem is deeper
            return solve_part_two(programs, bad_child_name);
        }
    }

    let diff = majority as i32 - *odd as i32;
    (bad_child.weight as i32 + diff) as u32
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let programs = parse(&input);
    let part_one = solve_part_one(&programs).unwrap();
    println!("Part one: {}", part_one);
    let part_two = solve_part_two(&programs, &part_one);
    println!("Part two: {}", part_two);
}
