use std::fs;

#[derive(Clone)]
pub enum Step {
    Up,
    Down,
    Left,
    Right,
}

#[derive(Clone)]
pub struct Sequence {
    pub steps: Vec<Step>,
}

#[derive(Clone)]
pub struct Input {
    pub lines: Vec<Sequence>,
}

pub fn parse_input(path: &str) -> Input {
    let data = fs::read_to_string(path).unwrap();
    let lines = data
        .lines()
        .map(|line| {
            let mut steps = Vec::new();
            for c in line.chars() {
                match c {
                    'U' => steps.push(Step::Up),
                    'D' => steps.push(Step::Down),
                    'L' => steps.push(Step::Left),
                    'R' => steps.push(Step::Right),
                    _ => panic!("Invalid character"),
                }
            }
            Sequence { steps }
        })
        .collect();

    Input { lines }
}
