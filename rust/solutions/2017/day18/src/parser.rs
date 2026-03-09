use std::collections::HashMap;

pub enum ValueType {
    Reg(char),
    Int(i64),
}

impl ValueType {
    pub fn get_value(&self, registers: &mut HashMap<char, i64>) -> i64 {
        match self {
            ValueType::Reg(reg) => *registers.entry(*reg).or_insert(0),
            ValueType::Int(value) => *value,
        }
    }
}

impl std::fmt::Display for ValueType {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            ValueType::Reg(reg) => write!(f, "{}", reg),
            ValueType::Int(value) => write!(f, "{}", value),
        }
    }
}

pub enum Instruction {
    Snd(char),
    Rcv(char),
    Set(char, ValueType),
    Add(char, ValueType),
    Mul(char, ValueType),
    Mod(char, ValueType),
    Jgz(ValueType, ValueType),
}

pub fn parse_instructions(input: &str) -> Vec<Instruction> {
    let mut instructions: Vec<Instruction> = Vec::new();
    for line in input.lines() {
        let parts = line
            .split_whitespace()
            .map(|l| l.trim())
            .collect::<Vec<&str>>();
        match parts.len() {
            2 => {
                // examples:
                // snd a
                // rcv b
                let reg = parts[1].chars().next().unwrap();
                match parts[0] {
                    "snd" => instructions.push(Instruction::Snd(reg)),
                    "rcv" => instructions.push(Instruction::Rcv(reg)),
                    _ => panic!("unknown cmd: {}", line),
                }
            }
            3 => {
                // examples:
                // set a 1
                // add b -1
                let target_reg: ValueType = match parts[1].parse::<i64>() {
                    Ok(value) => ValueType::Int(value),
                    Err(_) => {
                        let reg = parts[1].chars().next().unwrap();
                        ValueType::Reg(reg)
                    }
                };

                let target_reg_char = parts[1].chars().next().unwrap();

                let value: ValueType = match parts[2].parse::<i64>() {
                    Ok(value) => ValueType::Int(value),
                    Err(_) => {
                        let reg = parts[2].chars().next().unwrap();
                        ValueType::Reg(reg)
                    }
                };
                match parts[0] {
                    "set" => instructions.push(Instruction::Set(target_reg_char, value)),
                    "add" => instructions.push(Instruction::Add(target_reg_char, value)),
                    "mul" => instructions.push(Instruction::Mul(target_reg_char, value)),
                    "mod" => instructions.push(Instruction::Mod(target_reg_char, value)),
                    "jgz" => instructions.push(Instruction::Jgz(target_reg, value)),
                    _ => panic!("unknown cmd: {}", line),
                }
            }
            _ => panic!("Invalid line: {}", line),
        }
    }
    instructions
}
