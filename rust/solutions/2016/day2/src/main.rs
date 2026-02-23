mod simulation;
mod types;

use simulation::solve;
use types::parse_input;

fn main() {
    let input = parse_input("input.txt");
    let grid_p1: Vec<Vec<Option<char>>> = vec![
        vec![Some('1'), Some('2'), Some('3')],
        vec![Some('4'), Some('5'), Some('6')],
        vec![Some('7'), Some('8'), Some('9')],
    ];

    let grid_p2: Vec<Vec<Option<char>>> = vec![
        vec![None, None, Some('1'), None, None],
        vec![None, Some('2'), Some('3'), Some('4'), None],
        vec![Some('5'), Some('6'), Some('7'), Some('8'), Some('9')],
        vec![None, Some('A'), Some('B'), Some('C'), None],
        vec![None, None, Some('D'), None, None],
    ];

    let p1 = solve(&input, &grid_p1, 1, 1);
    println!("Part 1: {}", p1);

    let p2 = solve(&input, &grid_p2, 0, 2);
    println!("Part 2: {}", p2);
}
