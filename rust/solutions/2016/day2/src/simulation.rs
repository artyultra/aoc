use crate::types::{Input, Step};

pub fn solve(
    input: &Input,
    grid: &Vec<Vec<Option<char>>>,
    start_x: usize,
    start_y: usize,
) -> String {
    let mut x = start_x;
    let mut y = start_y;
    let mut code = String::new();

    for line in &input.lines {
        for step in &line.steps {
            let (nx, ny) = match step {
                Step::Up if y > 0 => (x, y - 1),
                Step::Down => (x, y + 1),
                Step::Left if x > 0 => (x - 1, y),
                Step::Right => (x + 1, y),
                _ => (x, y),
            };

            if ny < grid.len() && nx < grid[ny].len() {
                if grid[ny][nx].is_some() {
                    x = nx;
                    y = ny;
                }
            }
        }
        code.push(grid[y][x].unwrap());
    }

    code
}
