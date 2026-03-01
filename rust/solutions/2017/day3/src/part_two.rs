use std::collections::HashMap;

pub fn solve_part2(target: u32) -> u32 {
    let mut grid: HashMap<(i32, i32), u32> = HashMap::new();
    grid.insert((0, 0), 1);

    let dirs: [(i32, i32); 4] = [(1, 0), (0, 1), (-1, 0), (0, -1)];
    let mut x: i32 = 0;
    let mut y: i32 = 0;
    let mut dir = 0;
    let mut steps = 1;
    let mut steps_taken = 0;
    let mut turns = 0;

    loop {
        x += dirs[dir].0;
        y += dirs[dir].1;
        steps_taken += 1;

        let mut sum = 0;
        for dx in -1..=1 {
            for dy in -1..=1 {
                if dx == 0 && dy == 0 {
                    continue;
                }
                sum += grid.get(&(x + dx, y + dy)).unwrap_or(&0);
            }
        }

        if sum > target {
            return sum;
        }
        grid.insert((x, y), sum);

        if steps_taken == steps {
            steps_taken = 0;
            dir = (dir + 1) % 4;
            turns += 1;
            if turns % 2 == 0 {
                steps += 1;
            }
        }
    }
}
