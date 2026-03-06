use std::fs;

fn solve_p1(input: &str) -> (u32, u32) {
    let mut depth: u32 = 0;
    let mut score: u32 = 0;
    let mut garbage_count: u32 = 0;
    let mut in_garbage = false;
    let mut skip = false;

    for c in input.chars() {
        if skip {
            skip = false;
            continue;
        }
        if in_garbage {
            match c {
                '!' => skip = true,
                '>' => in_garbage = false,
                _ => garbage_count += 1,
            }
        } else {
            match c {
                '{' => depth += 1,
                '}' => {
                    score += depth;
                    depth -= 1;
                }
                '<' => in_garbage = true,
                _ => (),
            }
        }
    }

    (score, garbage_count)
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let (score, garbage_count) = solve_p1(&input);
    println!("Part 1: {}", score);
    println!("Part 2: {}", garbage_count);
}
