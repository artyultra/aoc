use std::{collections::VecDeque, fs};

fn parse_input(input: &str) -> (u64, u64) {
    let nums: Vec<u64> = input
        .lines()
        .map(|l| l.split_whitespace().last().unwrap().parse::<u64>().unwrap())
        .collect();
    (nums[0], nums[1])
}

struct Duel {
    a: u64,
    b: u64,
    factors: (u64, u64),
}

impl Duel {
    fn new(a: u64, b: u64) -> Duel {
        Duel {
            a,
            b,
            factors: (16807, 48271),
        }
    }

    fn reset(&mut self, a: u64, b: u64) {
        self.a = a;
        self.b = b;
    }

    fn next(&mut self) {
        let (fa, fb) = self.factors;
        let next_a = fa * self.a % 2147483647;
        let next_b = fb * self.b % 2147483647;
        self.a = next_a;
        self.b = next_b;
    }

    fn next_a(&mut self) -> Option<u64> {
        let (fa, _) = self.factors;
        let na = fa * self.a % 2147483647;
        self.a = na;
        if na % 4 == 0 {
            return Some(na);
        }
        None
    }

    fn next_b(&mut self) -> Option<u64> {
        let (_, fb) = self.factors;
        let nb = fb * self.b % 2147483647;
        self.b = nb;
        if nb % 8 == 0 {
            return Some(nb);
        }
        None
    }

    fn compare(&self) -> bool {
        self.a & 0xFFFF == self.b & 0xFFFF
    }

    fn run(&mut self) -> u64 {
        let mut count = 0;
        for _ in 0..40000000 {
            self.next();
            if self.compare() {
                count += 1;
            }
        }
        count
    }

    fn run2(&mut self) -> u64 {
        let mut count = 0;
        let mut pairs_checked = 0;
        let mut queue_a: VecDeque<u64> = VecDeque::new();
        let mut queue_b: VecDeque<u64> = VecDeque::new();
        loop {
            if pairs_checked > 5000000 {
                break;
            }
            if let Some(a) = self.next_a() {
                queue_a.push_back(a);
            }
            if let Some(b) = self.next_b() {
                queue_b.push_back(b);
            }
            if queue_a.len() > 0 && queue_b.len() > 0 {
                pairs_checked += 1;
                let a = queue_a.pop_front().unwrap();
                let b = queue_b.pop_front().unwrap();
                if a & 0xFFFF == b & 0xFFFF {
                    count += 1;
                }
            }
        }
        count
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let (a, b) = parse_input(&input);
    let mut duel = Duel::new(a, b);

    let p1 = duel.run();
    println!("Part 1: {}", p1);

    duel.reset(a, b);

    let p2 = duel.run2();
    println!("Part 2: {}", p2);
}
