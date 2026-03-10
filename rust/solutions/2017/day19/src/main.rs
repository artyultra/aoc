mod parser;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let input = input.trim_end_matches('\n');
    let mut diagram = parser::Diagram::new(&input);
    // diagram.print_display();
    while diagram.advance_next() {
        // diagram.print_display();
    }
    let p1: String = diagram.letters.iter().collect();
    println!("P1: {}", p1);
    println!("P2: Steps {}", diagram.steps);
}
