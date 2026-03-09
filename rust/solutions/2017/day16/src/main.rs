mod parser;

use std::fs;

struct DanceMachine {
    programs: Vec<char>,
    moves: Vec<parser::Move>,
}

impl DanceMachine {
    fn new(moves: Vec<parser::Move>) -> DanceMachine {
        let programs = vec![
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
        ];
        DanceMachine { programs, moves }
    }

    fn spin(&mut self, n: u32) {
        self.programs.rotate_right(n as usize);
    }

    fn exchange(&mut self, a: usize, b: usize) {
        self.programs.swap(a, b);
    }

    fn partner(&mut self, a: char, b: char) {
        let a_idx = self.programs.iter().position(|x| *x == a).unwrap();
        let b_idx = self.programs.iter().position(|x| *x == b).unwrap();
        self.programs.swap(a_idx, b_idx);
    }

    fn execute_moves(&mut self) {
        for m in self.moves.clone() {
            match m {
                parser::Move::Spin(n) => self.spin(n),

                parser::Move::Exchange(a, b) => self.exchange(a, b),
                parser::Move::Partner(a, b) => self.partner(a, b),
            }
        }
    }

    fn solve(&mut self) -> (String, String) {
        let initial = self.programs.clone();
        let mut p1 = String::new();
        for i in 0..1000000000 {
            self.execute_moves();
            if i == 0 {
                p1 = self.programs.iter().collect();
            }
            if self.programs == initial {
                let remaining = 1_000_000_000 % (i + 1);
                for _ in 0..remaining {
                    self.execute_moves();
                }
                let p2 = self.programs.iter().collect();
                return (p1, p2);
            }
        }
        let p2 = self.programs.iter().collect();
        (p1, p2)
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let moves = parser::parse_input(&input);
    let mut dance_machine = DanceMachine::new(moves);
    let (p1, p2) = dance_machine.solve();
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
