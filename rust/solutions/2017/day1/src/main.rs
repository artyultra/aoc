use std::fs;

pub fn solve(input_str: &str) -> (u32, u32) {
    let digits: Vec<u32> = input_str
        .trim()
        .chars()
        .map(|c| c.to_digit(10).unwrap() as u32)
        .collect();
    let mut sum: u32 = 0;
    let mut sum2: u32 = 0;
    for i in 0..digits.len() {
        let a = digits[i];
        let next = (i + 1) % digits.len();
        let next2 = (i + digits.len() / 2) % digits.len();
        let b = digits[next];
        let b2 = digits[next2];
        if a == b {
            sum += a;
        }
        if a == b2 {
            sum2 += a;
        }
    }
    (sum, sum2)
}

fn main() {
    // "9127340192837410293471923874..."
    let input_str = fs::read_to_string("input.txt").unwrap();
    let (part1, part2) = solve(&input_str);
    println!("Part 1: {}", part1);
    println!("Part 2: {}", part2);
}
