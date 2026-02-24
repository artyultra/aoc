use regex::Regex;
use std::fs;

pub fn parse_lines(path: &str) -> Vec<String> {
    let data = fs::read_to_string(path).unwrap().trim().to_string();
    data.lines().map(|l| l.to_string()).collect()
}

pub struct IpAddress {
    pub inners: Vec<String>,
    pub outers: Vec<String>,
}

pub fn parse_addr(line: &str) -> IpAddress {
    let outters = parse_outters(line);
    let inners = parse_inners(line);
    IpAddress {
        inners,
        outers: outters,
    }
}

pub fn parse_inners(line: &str) -> Vec<String> {
    let mut inners: Vec<String> = Vec::new();
    let re = Regex::new(r"(\[(\w+)\])").unwrap();
    for cap in re.captures_iter(line) {
        inners.push(cap[2].to_string());
    }
    inners
}

pub fn parse_outters(line: &str) -> Vec<String> {
    let re = Regex::new(r"(\[(\w+)\])").unwrap();
    let cleaned = re.replace_all(line, ",");
    cleaned.split(",").map(|s| s.to_string()).collect()
}
