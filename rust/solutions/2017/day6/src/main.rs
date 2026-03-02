use std::{collections::HashMap, fs};

fn redistribute(banks: &mut Vec<u32>, start: usize, value: &u32) {
    let mut idx = start;
    let mut to_distribute = *value as i32;
    banks[start] = 0;
    while to_distribute > 0 {
        idx = if idx == banks.len() - 1 { 0 } else { idx + 1 };
        banks[idx] += 1;
        to_distribute -= 1;
    }
}

fn solve(input_dat: &str) -> (u32, u32) {
    let mut banks = input_dat
        .split_whitespace()
        .map(|s| s.parse::<u32>().unwrap())
        .collect::<Vec<u32>>();
    let mut configs: HashMap<String, u32> = HashMap::new();
    let mut cycles = 0;
    loop {
        let (idx, &max_val) = banks
            .iter()
            .enumerate()
            .max_by(|(i1, v1), (i2, v2)| v1.cmp(v2).then(i2.cmp(i1)))
            .unwrap();

        redistribute(&mut banks, idx, &max_val);

        let key = banks
            .iter()
            .map(|n| n.to_string())
            .collect::<Vec<String>>()
            .join(" ");

        println!("{}", key);

        cycles += 1;
        match configs.get(&key) {
            Some(val) => {
                let part_one = cycles;
                let part_two = cycles - val;
                return (part_one, part_two);
            }
            None => {
                configs.insert(key, cycles);
            }
        }
    }
}

fn main() {
    let input_dat = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let (part_one, part_two) = solve(&input_dat);
    println!("Part One: {}", part_one);
    println!("Part Two: {}", part_two);
}
