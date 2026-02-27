mod parser;

use parser::{Dest, Input};
use std::collections::HashMap;

fn main() {
    let input = Input::new("input.txt");
    let mut solve_part_one = Solve::new(input);
    solve_part_one.solve();
}

struct Solve {
    input: Input,
    bots: HashMap<u32, Vec<u32>>,
    outputs: HashMap<u32, Vec<u32>>,
}

impl Solve {
    fn new(input: Input) -> Solve {
        let mut bots: HashMap<u32, Vec<u32>> = HashMap::new();
        let outputs: HashMap<u32, Vec<u32>> = HashMap::new();

        for init_val in &input.init_values {
            bots.entry(init_val.bot)
                .or_insert(Vec::new())
                .push(init_val.value);
        }
        Solve {
            input,
            bots,
            outputs,
        }
    }

    pub fn solve(self: &mut Self) {
        loop {
            let mut action = None;

            for command in &self.input.commands {
                if let Some(chips) = self.bots.get(&command.bot) {
                    if chips.len() == 2 {
                        let low = *chips.iter().min().unwrap();
                        let high = *chips.iter().max().unwrap();
                        action = Some((
                            command.bot,
                            low,
                            high,
                            command.low.clone(),
                            command.high.clone(),
                        ));
                        break;
                    }
                }
            }

            match action {
                Some((bot, low, hight, low_dest, high_dest)) => {
                    self.bots.get_mut(&bot).unwrap().clear();
                    self.distribute(low, &low_dest);
                    self.distribute(hight, &high_dest);

                    if low == 17 && hight == 61 {
                        println!("part one: {}", bot);
                    }
                }
                None => break,
            }
        }

        let output0 = self.outputs.get(&0).unwrap()[0];
        let output1 = self.outputs.get(&1).unwrap()[0];
        let output2 = self.outputs.get(&2).unwrap()[0];
        let product = output0 * output1 * output2;
        println!("part two: {}", product);
    }

    fn distribute(&mut self, val: u32, dest: &Dest) {
        match dest {
            Dest::Bot(bot) => self.bots.entry(*bot).or_insert(Vec::new()).push(val),
            Dest::Output(output) => self.outputs.entry(*output).or_insert(Vec::new()).push(val),
        }
    }
}
