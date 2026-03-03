use std::collections::HashMap;
use std::fmt;

#[allow(dead_code)]
pub struct Program {
    pub weight: u32,
    pub children: Vec<String>,
}

pub fn parse(input: &str) -> HashMap<String, Program> {
    let lines = input.lines().collect::<Vec<&str>>();
    let mut programs: HashMap<String, Program> = HashMap::new();
    for line in lines {
        // example: fwft (72) -> ktlj, cntj, xhth
        let parts: Vec<&str> = line.split_whitespace().collect();
        let name = parts[0];
        let weight = parts[1]
            .replace("(", "")
            .replace(")", "")
            .parse::<u32>()
            .unwrap();
        // parts[2] is the arrow
        let children: Vec<&str> = if parts.len() > 3 {
            parts[3..].iter().map(|s| s.trim_matches(',')).collect()
        } else {
            Vec::new()
        };
        programs.insert(
            name.to_string(),
            Program {
                weight,
                children: children.iter().map(|s| s.to_string()).collect(),
            },
        );
    }
    programs
}

impl fmt::Display for Program {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.children.is_empty() {
            write!(f, "({})", self.weight)
        } else {
            write!(f, "({}) -> {}", self.weight, self.children.join(", "))
        }
    }
}
