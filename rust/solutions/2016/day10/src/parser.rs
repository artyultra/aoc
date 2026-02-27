use std::fs;

pub struct InitValue {
    pub bot: u32,
    pub value: u32,
}

#[derive(Clone)]
pub enum Dest {
    Bot(u32),
    Output(u32),
}

#[allow(dead_code)]
pub struct Command {
    pub bot: u32,
    pub high: Dest,
    pub low: Dest,
}

#[allow(dead_code)]
pub struct Input {
    pub init_values: Vec<InitValue>,
    pub commands: Vec<Command>,
}

impl Input {
    pub fn new(path: &str) -> Input {
        let mut inits: Vec<InitValue> = Vec::new();
        let mut commands: Vec<Command> = Vec::new();

        let data = fs::read_to_string(path).unwrap();
        let lines: Vec<String> = data.lines().map(|line| line.to_string()).collect();

        for line in lines {
            if line.starts_with("value") {
                Self::parse_init_value(&line, &mut inits);
                continue;
            } else {
                Self::parse_command(&line, &mut commands);
            }
        }
        Input {
            init_values: inits,
            commands: commands,
        }
    }

    fn parse_init_value(line: &str, inits: &mut Vec<InitValue>) {
        // "value <val> goes to bot <bot>"
        let parts: Vec<&str> = line.split_whitespace().collect();

        if let ["value", value, "goes", "to", "bot", bot] = parts.as_slice() {
            let value: u32 = value.parse().unwrap();
            let bot: u32 = bot.parse().unwrap();

            inits.push(InitValue { bot, value });
        } else {
            panic!("invalid line: {line}");
        }
    }

    fn parse_command(line: &str, commands: &mut Vec<Command>) {
        // "bot <bot> gives low to bot <bot2> and high to bot <bot3>"
        let parts: Vec<&str> = line.split_whitespace().collect();

        if let [
            "bot",
            bot,
            "gives",
            "low",
            "to",
            low_kind,
            low_id,
            "and",
            "high",
            "to",
            high_kind,
            high_id,
        ] = parts.as_slice()
        {
            let bot: u32 = bot.parse().unwrap();
            let low = Self::parse_dest(low_kind, low_id);
            let high = Self::parse_dest(high_kind, high_id);

            commands.push(Command { bot, low, high });
        } else {
            panic!("invalid line: {line}");
        }
    }

    fn parse_dest(kind: &str, id: &str) -> Dest {
        let n: u32 = id.parse().unwrap();
        match kind {
            "bot" => Dest::Bot(n),
            "output" => Dest::Output(n),
            _ => panic!("invalid line: {kind}"),
        }
    }
}
