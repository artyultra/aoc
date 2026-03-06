use std::collections::HashMap;

pub fn parse_pipes_map(input: &str) -> HashMap<u32, Vec<u32>> {
    let mut map = HashMap::new();
    for line in input.lines() {
        // example: 344 <-> 409, 527, 1364, 1756
        let parts = line.split(" <-> ").collect::<Vec<&str>>();
        let pipe = parts[0].parse::<u32>().unwrap();
        let pipes = parts[1]
            .split(", ")
            .map(|p| p.parse::<u32>().unwrap())
            .collect::<Vec<u32>>();
        for p in &pipes {
            map.entry(*p).or_insert_with(Vec::new).push(pipe);
        }
        map.insert(pipe, pipes);
    }
    map
}
