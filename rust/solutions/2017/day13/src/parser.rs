use std::collections::HashMap;

pub type ScannerMap = HashMap<u32, u32>;

pub fn parse_input(input: &str) -> (ScannerMap, u32) {
    let mut map = HashMap::new();
    let mut max: u32 = 0;
    for line in input.lines() {
        let parts = line
            .split(": ")
            .map(|n| n.parse::<u32>().unwrap())
            .collect::<Vec<u32>>();
        let layer = parts[0];
        if layer > max {
            max = layer;
        }
        let range = parts[1];
        map.insert(layer, range);
    }
    (map, max)
}
