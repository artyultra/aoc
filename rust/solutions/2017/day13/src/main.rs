mod parser;

use std::time::Duration;
use std::{fmt, fs, thread};

type Map = std::collections::HashMap<u32, u32>;

struct Simulation {
    map: Map,
    max_layer: u32,
    packet_pos: i32,
    picosecond: u32,
    severity: u32,
    caught: bool,
}

impl Simulation {
    fn new(map: Map, max_layer: u32) -> Simulation {
        Simulation {
            map,
            max_layer,
            packet_pos: -1,
            picosecond: 0,
            severity: 0,
            caught: false,
        }
    }

    fn print_display(&self) {
        println!("\x1b[2J\x1B[H");
        println!(
            "picosecond: {} | severity: {} \n{}\n",
            self.picosecond, self.severity, self
        );
        thread::sleep(Duration::from_millis(100));
    }

    fn scanner_pos(&self, range: u32, time: u32) -> u32 {
        let cycle = (range - 1) * 2;
        let t = time % cycle;
        if t < range {
            t
        } else {
            cycle - t
        }
    }

    fn is_caught(&self) -> bool {
        if let Some(&range) = self.map.get(&(self.packet_pos as u32)) {
            self.scanner_pos(range, self.picosecond) == 0
        } else {
            false
        }
    }

    fn run(&mut self) -> u32 {
        for t in 0..=self.max_layer {
            self.packet_pos = t as i32;
            self.picosecond = t;

            // frame 1: packet arrives, scanners at current position
            self.print_display();

            if self.is_caught() {
                self.caught = true;
                let range = self.map.get(&t).unwrap();
                self.severity += t * range;
                self.print_display();
                thread::sleep(Duration::from_millis(500));
            }

            // frame 2: scanners advance
            self.picosecond = t + 1;
            self.print_display();
        }
        self.severity
    }

    fn run_p2(&mut self) -> u32 {
        let mut delay: u32 = 0;
        loop {
            let caught = self.map.iter().any(|(&layer, &range)| {
                let cycle = (range - 1) * 2;
                (layer + delay) % cycle == 0
            });
            if !caught {
                return delay;
            }
            delay += 1;
        }
    }
}

impl fmt::Display for Simulation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let max_range = self.map.values().copied().max().unwrap_or(0);
        let max_range = if max_range > 30 { 30 } else { max_range };
        let window_size: u32 = 12;

        let (start, end) = if self.max_layer <= window_size {
            (0, self.max_layer)
        } else {
            let half = window_size / 2;
            let pos = self.packet_pos.max(0) as u32;
            let start = if pos < half { 0 } else { pos - half };
            let end = (start + window_size).min(self.max_layer);
            let start = if end == self.max_layer {
                end - window_size
            } else {
                start
            };
            (start, end)
        };

        for layer in start..=end {
            write!(f, " {:^3} ", layer)?;
        }
        writeln!(f)?;

        for row in 0..max_range {
            for layer in start..=end {
                let is_packet_here = self.packet_pos == layer as i32 && row == 0;

                if let Some(&range) = self.map.get(&layer) {
                    if row < range {
                        let scanner_here = self.scanner_pos(range, self.picosecond) == row;
                        match (is_packet_here, scanner_here) {
                            (true, true) => write!(f, " \x1b[1;31m(S)\x1b[0m ")?,
                            (true, false) => write!(f, " ( ) ")?,
                            (false, true) => write!(f, " [s] ")?,
                            (false, false) => write!(f, " [ ] ")?,
                        }
                    } else {
                        write!(f, "     ")?;
                    }
                } else if row == 0 {
                    if is_packet_here {
                        write!(f, " (.) ")?;
                    } else {
                        write!(f, " ... ")?;
                    }
                } else {
                    write!(f, "     ")?;
                }
            }
            writeln!(f)?;
        }

        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let (map, max_layer) = parser::parse_input(&input);
    let mut sim = Simulation::new(map, max_layer);
    let p1 = sim.run();
    println!("Part 1: {}", p1);
    let p2 = sim.run_p2();
    println!("Part 2: {}", p2);
}
