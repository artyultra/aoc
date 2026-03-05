mod parser;

use parser::{parse_instructions, Instruction, Registers};

use std::collections::HashMap;
use std::fs;

fn solve(instructions: &Vec<Instruction>) -> (i32, i32) {
    let mut registers: Registers = HashMap::new();
    let mut max = 0;
    for ins in instructions {
        let reg_val = registers.get(&ins.reg).unwrap_or(&0);
        if ins.condition.check(&registers) {
            let new_val = ins.op.apply(*reg_val);
            if new_val > max {
                max = new_val;
            };
            registers.insert(ins.reg.to_string(), new_val);
        }
    }
    (registers.values().max().unwrap().clone(), max)
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let instructions = parse_instructions(&input);
    let (p1, p2) = solve(&instructions);
    println!("Part one: {}", p1);
    println!("Part two: {}", p2);
}
