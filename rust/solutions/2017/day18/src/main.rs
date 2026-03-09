mod parser;
use parser::{parse_instructions, Instruction as Ins};
use std::{
    collections::{HashMap, VecDeque},
    fs,
};

type Registers = HashMap<char, i64>;

fn print_registers(registers: &Registers) {
    println!("\x1b[2J\x1B[H");
    let mut sorted: Vec<_> = registers.iter().collect();
    sorted.sort_by_key(|(k, _)| *k);
    for (k, v) in sorted {
        println!("{}: {}", k, v);
    }
}

fn solve_p1(instructions: &Vec<Ins>) -> i64 {
    let mut registers: HashMap<char, i64> = HashMap::new();
    let mut recovery_freq: i64 = 0;
    let mut current_idx: i64 = 0;
    loop {
        if current_idx < 0 || current_idx >= instructions.len() as i64 {
            break;
        }
        let instruction = &instructions[current_idx as usize];
        match instruction {
            Ins::Snd(reg) => {
                let reg_freq = registers.entry(*reg).or_insert(0);
                recovery_freq = *reg_freq;
            }
            Ins::Rcv(reg) => {
                let reg_freq = registers.entry(*reg).or_insert(0);
                if *reg_freq != 0 {
                    break;
                }
            }
            Ins::Set(reg, value) => {
                let new_freq = value.get_value(&mut registers);
                registers.insert(*reg, new_freq);
            }
            Ins::Add(reg, value) => {
                let to_add = value.get_value(&mut registers);
                registers
                    .entry(*reg)
                    .and_modify(|e| *e += to_add)
                    .or_insert(to_add);
            }
            Ins::Mul(reg, value) => {
                let to_mul = value.get_value(&mut registers);
                registers
                    .entry(*reg)
                    .and_modify(|e| *e *= to_mul)
                    .or_insert(0);
            }
            Ins::Mod(reg, value) => {
                let to_mod = value.get_value(&mut registers);
                registers
                    .entry(*reg)
                    .and_modify(|e| *e %= to_mod)
                    .or_insert(0);
            }
            Ins::Jgz(reg, value) => {
                let reg_check = reg.get_value(&mut registers);
                if reg_check > 0 {
                    let to_jmp = value.get_value(&mut registers);
                    current_idx += to_jmp;
                    continue;
                }
            }
        }
        print_registers(&registers);

        current_idx += 1 % instructions.len() as i64;
    }
    recovery_freq
}

fn execute_instruction(
    instruction: &Ins,
    registers: &mut Registers,
    q_send: &mut VecDeque<i64>,
    q_rcv: &mut VecDeque<i64>,
    count: &mut i64,
) -> (Option<i64>, bool) {
    match instruction {
        Ins::Snd(reg) => {
            let reg_val = registers.entry(*reg).or_insert(0);
            q_send.push_back(*reg_val);
            *count += 1;
            return (None, false);
        }
        Ins::Rcv(reg) => {
            if !q_rcv.is_empty() {
                let rcvd_val = q_rcv.pop_front().unwrap();
                registers.insert(*reg, rcvd_val);
                return (None, false);
            } else {
                return (None, true);
            }
        }
        Ins::Set(reg, value) => {
            let op_value = value.get_value(registers);
            registers.insert(*reg, op_value);
            return (None, false);
        }
        Ins::Add(reg, value) => {
            let op_value = value.get_value(registers);
            registers
                .entry(*reg)
                .and_modify(|e| *e += op_value)
                .or_insert(op_value);
            return (None, false);
        }
        Ins::Mul(reg, value) => {
            let op_value = value.get_value(registers);
            registers
                .entry(*reg)
                .and_modify(|e| *e *= op_value)
                .or_insert(0);
            return (None, false);
        }
        Ins::Mod(reg, value) => {
            let op_value = value.get_value(registers);
            registers
                .entry(*reg)
                .and_modify(|e| *e %= op_value)
                .or_insert(0);
            return (None, false);
        }
        Ins::Jgz(reg, value) => {
            let reg_val = reg.get_value(registers);
            let op_value = value.get_value(registers);
            if reg_val > 0 {
                return (Some(op_value), false);
            } else {
                return (None, false);
            }
        }
    }
}

fn solve_p2(instructions: &Vec<Ins>) -> i64 {
    let mut registers_a: HashMap<char, i64> = HashMap::new();
    registers_a.insert('p', 0);
    let mut q_send_a: VecDeque<i64> = VecDeque::new();
    let mut idx_a: i64 = 0;
    let mut a_waiting = false;
    let mut count_a = 0;

    let mut registers_b: HashMap<char, i64> = HashMap::new();
    registers_b.insert('p', 1);
    let mut q_send_b: VecDeque<i64> = VecDeque::new();
    let mut idx_b: i64 = 0;
    let mut b_waiting = false;
    let mut count_b = 0;

    loop {
        if q_send_a.len() > 0 {
            b_waiting = false;
        }
        if q_send_b.len() > 0 {
            a_waiting = false;
        }

        if a_waiting && b_waiting {
            println!("****** DONE *****");
            println!("Register A:");
            print_registers(&registers_a);
            println!("Register B:");
            print_registers(&registers_b);
            break;
        }

        // execute a instruction
        let (a_val, is_waiting_a) = execute_instruction(
            &instructions[idx_a as usize],
            &mut registers_a,
            &mut q_send_a,
            &mut q_send_b,
            &mut count_a,
        );
        if is_waiting_a {
            a_waiting = true;
        } else {
            match a_val {
                Some(val) => {
                    idx_a += val;
                }
                None => idx_a += 1,
            }
        }

        // execute b instruction
        let (b_val, is_waiting_b) = execute_instruction(
            &instructions[idx_b as usize],
            &mut registers_b,
            &mut q_send_b,
            &mut q_send_a,
            &mut count_b,
        );
        if is_waiting_b {
            b_waiting = true;
        } else {
            match b_val {
                Some(val) => {
                    idx_b += val;
                }
                None => idx_b += 1,
            }
        }
    }
    count_b
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let instructions = parse_instructions(&input);
    println!("Part 1: {}", solve_p1(&instructions));
    let p2 = solve_p2(&instructions);
    println!("Part 2: {}", p2);
}
