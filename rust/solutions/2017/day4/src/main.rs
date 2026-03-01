use std::fs;

fn solve_part_one(lines: &Vec<Vec<String>>) -> usize {
    let len = lines.len();
    let mut sum = 0;
    for line in lines {
        'inner: for i in 0..line.len() {
            for j in 0..line.len() {
                if i != j && line[i] == line[j] {
                    sum += 1;
                    break 'inner;
                }
            }
        }
    }
    len - sum
}

fn sort_word(word: &str) -> String {
    let mut chars: Vec<char> = word.chars().collect();
    chars.sort();
    chars.iter().collect()
}

fn solve_part_two(lines: &Vec<Vec<String>>) -> usize {
    let len = lines.len();
    let mut sum = 0;
    for line in lines {
        'inner: for i in 0..line.len() {
            for j in 0..line.len() {
                if i != j && sort_word(&line[i]) == sort_word(&line[j]) {
                    sum += 1;
                    break 'inner;
                }
            }
        }
    }
    len - sum
}

fn main() {
    let lines: Vec<Vec<String>> = fs::read_to_string("input.txt")
        .unwrap()
        .trim()
        .to_string()
        .lines()
        .map(|l| l.split(" ").map(|s| s.to_string()).collect::<Vec<String>>())
        .collect();

    let part_one = solve_part_one(&lines);
    println!("Part 1: {}", part_one);
    let part_two = solve_part_two(&lines);
    println!("Part 2: {}", part_two);
}
