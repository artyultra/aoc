use std::fs;

fn parse_lines(input: &str) -> Vec<Vec<u32>> {
    let lines = input
        .lines()
        .map(|l| l.trim().to_string())
        .collect::<Vec<String>>();

    lines
        .iter()
        .map(|line| {
            line.split_whitespace()
                .map(|n| n.parse::<u32>().unwrap())
                .collect::<Vec<u32>>()
        })
        .collect::<Vec<Vec<u32>>>()
}

fn solve(lines: &Vec<Vec<u32>>) -> (u32, u32) {
    let mut sum1 = 0;
    let mut sum2 = 0;
    for line in lines {
        sum1 += part1(line);
        let part2 = part2(line);
        if let Some(part2) = part2 {
            sum2 += part2;
        }
    }
    (sum1, sum2)
}

fn part1(line: &Vec<u32>) -> u32 {
    let min = line.iter().min().unwrap();
    let max = line.iter().max().unwrap();
    max - min
}

fn part2(nums: &Vec<u32>) -> Option<u32> {
    for n in nums {
        for n2 in nums {
            if n % n2 == 0 && n2 != n {
                println!("{} {}", n, n2);
                return Some(n / n2);
            }
        }
    }
    None
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let lines = parse_lines(&input);
    let (part1, part2) = solve(&lines);
    println!("part1: {}", part1);
    println!("part2: {}", part2);
}
