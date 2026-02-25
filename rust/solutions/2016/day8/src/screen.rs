use std::fmt;

pub struct Screen {
    pub width: usize,
    pub height: usize,
    pub pixels: Vec<bool>,
}

#[allow(dead_code)]
impl Screen {
    pub fn new() -> Screen {
        let w: usize = 50;
        let h: usize = 6;
        let pixels: Vec<bool> = vec![false; w * h];
        Screen {
            width: w,
            height: h,
            pixels: pixels,
        }
    }

    pub fn shift_column(&mut self, col: usize, offset: usize) {
        let w = self.width;
        let h = self.height;

        let column: Vec<bool> = (0..h).map(|row| self.pixels[row * w + col]).collect();

        for row in 0..h {
            let source = (row + h - offset % h) % h;
            self.pixels[row * w + col] = column[source];
        }
    }

    pub fn shift_row(&mut self, row: usize, offset: usize) {
        let w = self.width;

        let row_data: Vec<bool> = (0..w).map(|col| self.pixels[row * w + col]).collect();

        for col in 0..w {
            let source = (col + w - offset % w) % w;
            self.pixels[row * w + col] = row_data[source];
        }
    }

    pub fn turn_on_pixels(&mut self, w: usize, h: usize) {
        for row in 0..h {
            for col in 0..w {
                let idx = row * self.width + col;
                self.pixels[idx] = true;
            }
        }
    }

    pub fn count_on(&self) -> usize {
        self.pixels.iter().filter(|pixel| **pixel).count()
    }
}

impl fmt::Display for Screen {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for row in 0..self.height {
            for col in 0..self.width {
                if self.pixels[row * self.width + col] {
                    write!(f, "#")?;
                } else {
                    write!(f, " ")?;
                }
            }
            writeln!(f)?;
        }
        Ok(())
    }
}
