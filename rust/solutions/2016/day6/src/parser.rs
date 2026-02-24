use std::fs;

pub fn parse_input_lines(path: &str) -> Vec<String> {
    let data = fs::read_to_string(path).unwrap();
    data.lines().map(|l| l.to_string()).collect()
}
