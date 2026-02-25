use std::fs;

pub fn parse_input(path: &str) -> Vec<String> {
    let data = fs::read_to_string(path).unwrap();
    data.lines().map(|line| line.to_string()).collect()
}
