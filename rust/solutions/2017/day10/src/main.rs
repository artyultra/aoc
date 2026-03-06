use std::fs;

fn reverse_list(nums: &mut Vec<usize>, current: usize, length: usize) {
    let len = nums.len();
    // extract the circular slice
    let mut slice: Vec<usize> = (0..length).map(|i| nums[(current + i) % len]).collect();
    slice.reverse();

    // write it back
    for (i, val) in slice.iter().enumerate() {
        nums[(current + i) % len] = *val;
    }
}

fn convert_to_dense_hash(nums: &Vec<usize>) -> Vec<usize> {
    let mut hash: Vec<usize> = vec![0; 16];
    for i in 0..16 {
        let section = nums[i * 16..(i + 1) * 16]
            .iter()
            .copied()
            .fold(0, |acc, x| acc ^ x);
        hash[i] = section;
    }
    hash
}

fn solve2(lengths: &Vec<usize>) -> String {
    let mut nums: Vec<usize> = (0..=255).collect();
    let mut skip_size = 0;
    let mut current = 0;
    for _ in 0..64 {
        for length in lengths {
            reverse_list(&mut nums, current, *length);
            current = (current + length + skip_size) % nums.len();
            skip_size += 1;
        }
    }
    let hash = convert_to_dense_hash(&nums);
    hash.iter()
        .map(|x| format!("{:02x}", x))
        .collect::<String>()
}

fn solve(lengths: &Vec<usize>) -> u32 {
    let mut nums: Vec<usize> = (0..=255).collect();
    let mut skip_size = 0;
    let mut current = 0;
    for length in lengths {
        reverse_list(&mut nums, current, *length);
        current = (current + length + skip_size) % nums.len();
        skip_size += 1;
    }
    nums[0] as u32 * nums[1] as u32
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let lengths: Vec<usize> = input
        .split(",")
        .map(|s| s.parse::<usize>().unwrap())
        .collect();
    let p1 = solve(&lengths);
    println!("Part 1: {}", p1);

    let mut ascii_lengths: Vec<usize> = input.chars().map(|c| c as usize).collect();
    ascii_lengths.extend([17, 31, 73, 47, 23]);
    let p2 = solve2(&ascii_lengths);
    println!("Part 2: {}", p2);
}
