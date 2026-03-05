use std::collections::HashMap;

pub type Registers = HashMap<String, i32>;

pub enum Op {
    Increase(i32),
    Decrease(i32),
}

impl Op {
    pub fn apply(&self, value: i32) -> i32 {
        match self {
            Op::Increase(v) => value + v,
            Op::Decrease(v) => value - v,
        }
    }
}

pub enum Comparison {
    Equal,
    NotEqual,
    GreaterThan,
    LessThan,
    GreaterThanOrEqual,
    LessThanOrEqual,
}

pub struct Condition {
    pub reg: String,
    pub value: i32,
    pub comparison: Comparison,
}

impl Condition {
    pub fn check(&self, regs: &Registers) -> bool {
        let reg_val = regs.get(&self.reg).unwrap_or(&0);
        match self.comparison {
            Comparison::Equal => reg_val == &self.value,
            Comparison::NotEqual => reg_val != &self.value,
            Comparison::GreaterThan => reg_val > &self.value,
            Comparison::LessThan => reg_val < &self.value,
            Comparison::GreaterThanOrEqual => reg_val >= &self.value,
            Comparison::LessThanOrEqual => reg_val <= &self.value,
        }
    }
}

pub struct Instruction {
    pub reg: String,
    pub op: Op,
    pub condition: Condition,
}

pub fn parse_instructions(input: &str) -> Vec<Instruction> {
    let mut instructions: Vec<Instruction> = Vec::new();
    for line in input.lines() {
        // example: txm dec 835 if s != -8
        let parts: Vec<&str> = line.split_whitespace().collect();
        if let [reg, op, val, "if", reg_cond, comp, val_cond] = parts.as_slice() {
            let op = match *op {
                "inc" => Op::Increase(val.parse::<i32>().unwrap()),
                "dec" => Op::Decrease(val.parse::<i32>().unwrap()),
                _ => panic!("unknown op"),
            };
            let comparison = match *comp {
                ">" => Comparison::GreaterThan,
                "<" => Comparison::LessThan,
                ">=" => Comparison::GreaterThanOrEqual,
                "<=" => Comparison::LessThanOrEqual,
                "==" => Comparison::Equal,
                "!=" => Comparison::NotEqual,
                _ => panic!("unknown comparison"),
            };
            let condition = Condition {
                reg: reg_cond.to_string(),
                value: val_cond.parse::<i32>().unwrap(),
                comparison,
            };
            instructions.push(Instruction {
                reg: reg.to_string(),
                op,
                condition,
            });
        } else {
            panic!("unknown instruction");
        }
    }
    instructions
}
