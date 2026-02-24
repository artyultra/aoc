use std::fs;

pub fn parse_input_lines(path: &str) -> Vec<String> {
    let data = fs::read_to_string(path).unwrap();
    data.lines().map(|l| l.to_string()).collect()
}

pub fn parse_line(line: &str) -> (String, i32, String) {
    let parts: Vec<&str> = line.split('[').collect();
    let checksum = parts[1].trim_end_matches(']').to_string();

    let name_id = parts[0];
    let last_dash = name_id.rfind('-').unwrap();
    let name = &name_id[..last_dash];
    let id: i32 = name_id[last_dash + 1..].parse().unwrap();

    (name.to_string(), id, checksum)
}
