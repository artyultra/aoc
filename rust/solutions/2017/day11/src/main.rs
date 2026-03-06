use std::fs;

fn solve(path: Vec<&str>) -> (i32, i32) {
    let mut x: i32 = 0;
    let mut y: i32 = 0;
    let mut z: i32 = 0;
    let mut max_dist = 0;
    for dir in path {
        match dir {
            "n" => {
                y += 1;
                z -= 1;
            }
            "ne" => {
                x += 1;
                z -= 1;
            }
            "se" => {
                x += 1;
                y -= 1;
            }
            "s" => {
                y -= 1;
                z += 1;
            }
            "sw" => {
                x -= 1;
                z += 1;
            }
            "nw" => {
                x -= 1;
                y += 1;
            }
            _ => panic!("Invalid direction {dir}"),
        }
        let dist = x.abs().max(y.abs()).max(z.abs());
        if dist > max_dist {
            max_dist = dist;
        }
    }
    let final_dist = x.abs().max(y.abs()).max(z.abs());
    (final_dist, max_dist)
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let path = input.split(",").collect::<Vec<&str>>();
    let (p1, p2) = solve(path);
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
