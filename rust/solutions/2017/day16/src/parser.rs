#[derive(Clone)]
pub enum Move {
    Spin(u32),
    Exchange(usize, usize),
    Partner(char, char),
}

pub fn parse_input(input: &str) -> Vec<Move> {
    let mut moves: Vec<Move> = Vec::new();
    let move_strings = input.split(",").collect::<Vec<&str>>();
    for m in move_strings {
        // exs: sX, xA/B, pA/B
        if m.starts_with("s") {
            let n = m[1..].parse::<u32>().unwrap();
            moves.push(Move::Spin(n));
        } else if m.starts_with("x") {
            let parts: Vec<usize> = m[1..]
                .split("/")
                .map(|x| x.parse::<usize>().unwrap())
                .collect();
            moves.push(Move::Exchange(parts[0], parts[1]));
        }
        if m.starts_with("p") {
            let parts: Vec<char> = m[1..]
                .split("/")
                .map(|x| x.chars().next().unwrap())
                .collect();
            moves.push(Move::Partner(parts[0], parts[1]));
        }
    }
    moves
}
