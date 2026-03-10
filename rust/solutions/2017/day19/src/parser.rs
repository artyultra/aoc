#[allow(dead_code)]
pub enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl Direction {
    pub fn next_pos(&self, current: (usize, usize)) -> (isize, isize) {
        match self {
            Direction::Up => (current.0 as isize, current.1 as isize - 1),
            Direction::Down => (current.0 as isize, current.1 as isize + 1),
            Direction::Left => (current.0 as isize - 1, current.1 as isize),
            Direction::Right => (current.0 as isize + 1, current.1 as isize),
        }
    }
}

#[allow(dead_code)]
pub struct Diagram {
    pub width: usize,
    pub height: usize,
    pub grid: Vec<char>,
    pub direction: Direction,
    pub position: (usize, usize),
    pub letters: Vec<char>,
    pub steps: usize,
}

impl Diagram {
    pub fn new(input: &str) -> Diagram {
        let width = input.lines().map(|l| l.len()).max().unwrap();
        let height = input.lines().count();
        let grid: Vec<char> = input
            .lines()
            .flat_map(|l| {
                let mut chars: Vec<char> = l.chars().collect();
                chars.resize(width, ' ');
                chars
            })
            .collect();

        let start_x = grid.iter().position(|c| *c == '|').unwrap();
        let letters: Vec<char> = Vec::new();

        Diagram {
            width,
            height,
            grid,
            direction: Direction::Down,
            position: (start_x, 0),
            letters,
            steps: 1,
        }
    }

    pub fn get_char(&self, pos: (isize, isize)) -> char {
        let idx = pos.0 as usize + pos.1 as usize * self.width;
        self.grid[idx]
    }

    fn check_bounds(&self, pos: (isize, isize)) -> bool {
        pos.0 >= 0 && pos.0 < self.width as isize && pos.1 >= 0 && pos.1 < self.height as isize
    }

    pub fn advance_next(&mut self) -> bool {
        let next_pos = self.direction.next_pos(self.position);

        if !self.check_bounds(next_pos) {
            return false;
        }

        let next_char = self.get_char(next_pos);

        if next_char == ' ' {
            return false;
        }

        self.position = (next_pos.0 as usize, next_pos.1 as usize);
        self.steps += 1;

        if next_char.is_ascii_uppercase() {
            self.letters.push(next_char);
        }

        if next_char == '+' {
            let candidates = match self.direction {
                Direction::Up | Direction::Down => [Direction::Left, Direction::Right],
                Direction::Left | Direction::Right => [Direction::Up, Direction::Down],
            };
            for candidate in candidates {
                let test_pos = candidate.next_pos(self.position);
                if self.check_bounds(test_pos) && self.get_char(test_pos) != ' ' {
                    self.direction = candidate;
                    break;
                }
            }
        }
        true
    }

    #[allow(dead_code)]
    pub fn print_display(&self) {
        print!("\x1b[2J\x1B[H");
        println!(
            "pos: ({},{}) | dir: {} | letters: {} | steps: {}\n{}",
            self.position.0,
            self.position.1,
            match self.direction {
                Direction::Up => "↑",
                Direction::Down => "↓",
                Direction::Left => "←",
                Direction::Right => "→",
            },
            self.letters.iter().collect::<String>(),
            self.steps,
            self
        );
        std::thread::sleep(std::time::Duration::from_millis(200));
    }
}

impl std::fmt::Display for Diagram {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let window = 30usize;

        let half = window / 2;

        let (start_x, end_x) = if self.width <= window {
            (0, self.width)
        } else {
            let sx = if self.position.0 < half {
                0
            } else {
                self.position.0 - half
            };
            let ex = (sx + window).min(self.width);
            let sx = if ex == self.width { ex - window } else { sx };
            (sx, ex)
        };

        let (start_y, end_y) = if self.height <= window {
            (0, self.height)
        } else {
            let sy = if self.position.1 < half {
                0
            } else {
                self.position.1 - half
            };
            let ey = (sy + window).min(self.height);
            let sy = if ey == self.height { ey - window } else { sy };
            (sy, ey)
        };

        for y in start_y..end_y {
            for x in start_x..end_x {
                if x == self.position.0 && y == self.position.1 {
                    write!(f, "\x1b[1;32m# \x1b[0m")?;
                } else {
                    let idx = x + y * self.width;
                    let c = self.grid[idx];
                    match c {
                        '|' | '-' => write!(f, "\x1b[90m{} \x1b[0m", c)?, // dim gray for pipes
                        '+' => write!(f, "\x1b[33m{} \x1b[0m", c)?,       // yellow for corners
                        'A'..='Z' => write!(f, "\x1b[1;36m{} \x1b[0m", c)?, // bold cyan for letters
                        ' ' => write!(f, "  ")?,                          // blank stays blank
                        _ => write!(f, "{} ", c)?,
                    }
                }
            }
            writeln!(f)?;
        }

        Ok(())
    }
}
