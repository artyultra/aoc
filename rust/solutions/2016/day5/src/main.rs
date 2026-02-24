use md5;
use std::fs;
use std::io::{self, Write};

fn print_password_progress(password: &Vec<Option<char>>, counter: i32) {
    print!("\r");
    for c in password.iter() {
        if c.is_none() {
            print!("_");
        } else {
            print!("{}", c.unwrap());
        }
    }
    print!("  (checking: {})", counter);
    io::stdout().flush().unwrap();
}

fn solve_part_one(input: &str) -> String {
    let mut password: Vec<Option<char>> = vec![None; 8];
    let mut counter = 0;
    let mut found = 0;
    while found < 8 {
        let hex_string = format!("{:x}", md5::compute(format!("{}{}", input, counter)));
        if &hex_string[0..5] == "00000" {
            let sixth_char = hex_string.chars().nth(5).unwrap();
            password[found] = Some(sixth_char);
            found += 1;
        }
        print_password_progress(&password, counter);
        counter += 1;
    }
    println!();
    password.iter().map(|&x| x.unwrap()).collect()
}

fn solve_part_two(input: &str) -> String {
    let mut password: Vec<Option<char>> = vec![None; 8];
    let mut counter = 0;
    while password.iter().any(|&x| x.is_none()) {
        let hex_string = format!("{:x}", md5::compute(format!("{}{}", input, counter)));
        let first_five = &hex_string[0..5].to_string();
        if first_five == "00000" {
            let sixth_char = hex_string.chars().nth(5).unwrap();
            if sixth_char >= '0' && sixth_char <= '7' {
                let idx = sixth_char as usize - '0' as usize;
                if password[idx].is_none() {
                    let seventh_char = hex_string.chars().nth(6).unwrap();
                    password[idx] = Some(seventh_char);
                }
            }
        }
        print_password_progress(&password, counter);
        counter += 1;
    }
    println!();
    password.iter().map(|&x| x.unwrap()).collect()
}

fn main() {
    let input_dat = fs::read_to_string("input.txt").unwrap().trim().to_string();
    let part1 = solve_part_one(&input_dat);
    println!("{}", part1);
    let part2 = solve_part_two(&input_dat);
    println!("{}", part2);
}
