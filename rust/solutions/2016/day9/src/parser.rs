pub fn parse_input(path: &str) -> String {
    std::fs::read_to_string(path).unwrap().trim().to_string()
}
