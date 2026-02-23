pub struct Triangle {
    pub a: i32,
    pub b: i32,
    pub c: i32,
}

impl Triangle {
    pub fn is_valid(&self) -> bool {
        (self.a + self.b) > self.c && (self.a + self.c) > self.b && (self.b + self.c) > self.a
    }
}

pub fn parse_triangle_p1(data: &str) -> Vec<Triangle> {
    data.lines()
        .map(|line| {
            let mut parts = line.split_whitespace();
            Triangle {
                a: parts.next().unwrap().parse().unwrap(),
                b: parts.next().unwrap().parse().unwrap(),
                c: parts.next().unwrap().parse().unwrap(),
            }
        })
        .collect()
}

pub fn parse_triangle_p2(data: &str) -> Vec<Triangle> {
    let nums: Vec<i32> = data
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();

    let mut triangles = Vec::new();
    for chunk in nums.chunks(9) {
        triangles.push(Triangle {
            a: chunk[0],
            b: chunk[3],
            c: chunk[6],
        });
        triangles.push(Triangle {
            a: chunk[1],
            b: chunk[4],
            c: chunk[7],
        });
        triangles.push(Triangle {
            a: chunk[2],
            b: chunk[5],
            c: chunk[8],
        });
    }
    triangles
}
