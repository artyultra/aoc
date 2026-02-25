mod parser;
mod screen;

use parser::parse_input;
use screen::Screen;
use std::thread;
use std::time::Duration;

fn parse_rect(line: &str) -> (usize, usize) {
    // rect 1x1
    let mut parts = line.split(" ");
    let _ = parts.next();

    let dimensions = parts.next().unwrap();
    let mut xy = dimensions.split("x");
    let w: usize = xy.next().unwrap().parse().unwrap();
    let h: usize = xy.next().unwrap().parse().unwrap();
    (w, h)
}

enum Direction {
    Column,
    Row,
}

struct Rotate {
    target: usize,
    offset: usize,
    direction: Direction,
}

fn parse_rotate(line: &str) -> Rotate {
    // rotate (row|column) y|x=0 by 1
    let mut parts = line.split(" ");
    let _ = parts.next();
    let direction = if parts.next().unwrap() == "row" {
        Direction::Row
    } else {
        Direction::Column
    };
    let axis = parts.next().unwrap();
    let mut axis_parts = axis.split("=");
    let _ = axis_parts.next();
    let target: usize = axis_parts.next().unwrap().parse().unwrap();

    let _ = parts.next();
    let offset: usize = parts.next().unwrap().parse().unwrap();

    Rotate {
        direction: direction,
        target: target,
        offset: offset,
    }
}

fn main() {
    let lines = parse_input("input.txt");
    let mut screen = Screen::new();
    for line in lines {
        if line.contains("rect") {
            let (w, h) = parse_rect(&line);
            screen.turn_on_pixels(w, h);
        } else if line.contains("rotate") {
            let rotate = parse_rotate(&line);
            match rotate.direction {
                Direction::Row => {
                    screen.shift_row(rotate.target, rotate.offset);
                }
                Direction::Column => {
                    screen.shift_column(rotate.target, rotate.offset);
                }
            }
        }
        print!("\x1B[2J\x1B[H");
        println!("{}", screen);
        thread::sleep(Duration::from_millis(10));
    }
    println!("Count: {}", screen.count_on());
}
