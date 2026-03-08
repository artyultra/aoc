pub fn reverse_list(nums: &mut Vec<usize>, current: usize, length: usize) {
    let len = nums.len();
    let mut slice: Vec<usize> = (0..length).map(|i| nums[(current + i) % len]).collect();
    slice.reverse();
    for (i, val) in slice.iter().enumerate() {
        nums[(current + i) % len] = *val;
    }
}

pub fn convert_to_dense_hash(nums: &Vec<usize>) -> Vec<usize> {
    let mut hash: Vec<usize> = vec![0; 16];
    for i in 0..16 {
        hash[i] = nums[i * 16..(i + 1) * 16]
            .iter()
            .copied()
            .fold(0, |acc, x| acc ^ x);
    }
    hash
}

pub fn knot_hash(input: &str) -> String {
    let mut lengths: Vec<usize> = input.chars().map(|c| c as usize).collect();
    lengths.extend([17, 31, 73, 47, 23]);
    let mut nums: Vec<usize> = (0..=255).collect();
    let mut skip_size = 0;
    let mut current = 0;
    for _ in 0..64 {
        for &length in &lengths {
            reverse_list(&mut nums, current, length);
            current = (current + length + skip_size) % nums.len();
            skip_size += 1;
        }
    }
    let hash = convert_to_dense_hash(&nums);
    hash.iter()
        .map(|x| format!("{:02x}", x))
        .collect::<String>()
}
