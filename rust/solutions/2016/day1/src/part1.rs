use crate::common::{Direction, Op, Position};
use std::collections::HashSet;

struct SimState {
    dir: Direction,
    pos: Position,
    ops: Vec<Op>,
    visited: HashSet<(i32, i32)>,
}

impl SimState {
    fn new(ops: &Vec<Op>) -> SimState {
        let visited: HashSet<(i32, i32)> = HashSet::new();
        SimState {
            dir: Direction::North,
            pos: Position { x: 0, y: 0 },
            ops: ops.to_vec(),
            visited,
        }
    }

    fn move_one(&mut self) -> Option<i32> {
        match self.dir {
            Direction::North => self.pos.y += 1,
            Direction::East => self.pos.x += 1,
            Direction::South => self.pos.y -= 1,
            Direction::West => self.pos.x -= 1,
        }
        if !self.visited.insert((self.pos.x, self.pos.y)) {
            return Some(self.pos.x.abs() + self.pos.y.abs());
        }

        None
    }

    fn move_pos(&mut self, dist: i32) {
        match self.dir {
            Direction::North => self.pos.y += dist,
            Direction::East => self.pos.x += dist,
            Direction::South => self.pos.y -= dist,
            Direction::West => self.pos.x -= dist,
        }
    }

    fn step(&mut self, op: &Op) {
        match op.turn {
            'L' => self.dir = self.dir.turn_left(),
            'R' => self.dir = self.dir.turn_right(),
            _ => (),
        }
        self.move_pos(op.dist);
    }

    fn step_part_two(&mut self, op: &Op) -> Option<i32> {
        match op.turn {
            'L' => self.dir = self.dir.turn_left(),
            'R' => self.dir = self.dir.turn_right(),
            _ => (),
        }
        for _ in 0..op.dist {
            if let Some(dist) = self.move_one() {
                return Some(dist);
            }
        }
        None
    }
}

pub fn solve(ops: &Vec<Op>) -> i32 {
    let mut sim = SimState::new(ops);
    for i in 0..sim.ops.len() {
        let turn = sim.ops[i].turn;
        let dist = sim.ops[i].dist;
        sim.step(&Op { turn, dist });
    }
    sim.pos.x.abs() + sim.pos.y.abs()
}

pub fn solve_part_two(ops: &Vec<Op>) -> i32 {
    let mut sim = SimState::new(ops);
    for i in 0..sim.ops.len() {
        let turn = sim.ops[i].turn;
        let dist = sim.ops[i].dist;
        if let Some(dist) = sim.step_part_two(&Op { turn, dist }) {
            return dist;
        }
    }
    sim.pos.x.abs() + sim.pos.y.abs()
}
