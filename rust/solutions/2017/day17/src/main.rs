use std::fs;

fn solve(steps: u32) -> u32 {
    let mut buffer: Vec<u32> = Vec::new();
    let mut current: u32 = 0;
    buffer.push(0);
    for i in 1..=2017 {
        current = ((current + steps) % buffer.len() as u32) + 1;
        buffer.insert(current as usize, i);
    }
    buffer[(current as usize + 1) % buffer.len()]
}

fn slove_p2(steps: u32) -> u32 {
    let mut current: u32 = 0;
    let mut after_zero: u32 = 0;
    for i in 1..=50_000_000 {
        current = ((current + steps) % i) + 1;
        if current == 1 {
            after_zero = i;
        }
    }
    after_zero
}

fn main() {
    let steps = fs::read_to_string("input.txt")
        .unwrap()
        .trim()
        .to_string()
        .parse::<u32>()
        .unwrap();

    println!("Part 1: {}", solve(steps));

    println!("Part 2: {}", slove_p2(steps));
}
