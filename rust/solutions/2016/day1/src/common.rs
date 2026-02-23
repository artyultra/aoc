#[derive(Clone)]
pub struct Op {
    pub turn: char,
    pub dist: i32,
}

pub enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    pub fn turn_right(&self) -> Direction {
        match self {
            Direction::North => Direction::East,
            Direction::East => Direction::South,
            Direction::South => Direction::West,
            Direction::West => Direction::North,
        }
    }

    pub fn turn_left(&self) -> Direction {
        match self {
            Direction::North => Direction::West,
            Direction::East => Direction::North,
            Direction::South => Direction::East,
            Direction::West => Direction::South,
        }
    }
}

pub struct Position {
    pub x: i32,
    pub y: i32,
}
