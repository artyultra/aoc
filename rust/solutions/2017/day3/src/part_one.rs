fn get_ring_num_range(idx: u32) -> (u32, u32) {
    if idx == 0 {
        return (1, 1);
    }
    let start = (2 * (idx - 1) + 1).pow(2) + 1;
    let end = (2 * idx + 1).pow(2);
    (start, end)
}

fn get_offset(ring: u32, end: u32, num: &u32) -> u32 {
    let side_len = 2 * ring;
    let mut min_offset = u32::MAX;
    for i in 0..4 {
        let mid = end - ring - (i * side_len);
        let diff = mid.abs_diff(*num);
        if diff < min_offset {
            min_offset = diff;
        }
    }
    min_offset
}

pub fn solve_part1(num: &u32) -> u32 {
    let mut ring: u32 = 0;
    loop {
        let (start, end) = get_ring_num_range(ring);
        if *num >= start && *num <= end {
            let offset = get_offset(ring, end, num);
            return ring + offset;
        }
        ring += 1;
    }
}
