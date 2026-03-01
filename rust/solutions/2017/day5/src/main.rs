use std::fs;

fn solve_part1(instructions: &mut Vec<i32>) -> u32 {
    let mut steps: u32 = 0;
    let mut pos: i32 = 0;
    loop {
        if pos < 0 || pos >= instructions.len() as i32 {
            break;
        }
        let idx = pos as usize;
        let jump = instructions[idx];
        instructions[idx] += 1;
        pos += jump;
        steps += 1;
    }
    steps
}

fn solve_part2(instructions: &mut Vec<i32>) -> u32 {
    let mut steps: u32 = 0;
    let mut pos: i32 = 0;
    loop {
        if pos < 0 || pos >= instructions.len() as i32 {
            break;
        }
        let idx = pos as usize;
        let jump = instructions[idx];
        if jump >= 3 {
            instructions[idx] -= 1;
        } else {
            instructions[idx] += 1;
        }
        pos += jump;
        steps += 1;
    }
    steps
}

fn main() {
    let instructions: Vec<i32> = fs::read_to_string("input.txt")
        .unwrap()
        .trim()
        .to_string()
        .lines()
        .map(|l| l.parse::<i32>().unwrap())
        .collect();
    let mut instructions_p1 = instructions.clone();
    let mut instructions_p2 = instructions.clone();

    println!("Part 1: {}", solve_part1(&mut instructions_p1));
    println!("Part 2: {}", solve_part2(&mut instructions_p2));
}
