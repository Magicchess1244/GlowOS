use crate::println;
use crate::print;
use crate::get_words;

use alloc::{vec::Vec, string::String};

struct Command {
    name: &'static str,
    function: fn(Vec<String>),
    description: &'static str,
}

static COMMANDS: [Command; 2] = [
    Command {
        name: "echo",
        function: echo,
        description: "It will print anything you put in. Args will be separated by a ' ' when displaying it"
    },
    Command {
        name: "help",
        function: help,
        description: "It tells you the name of the commands and a short description"
    },
];

pub fn command_runner(){
    let cmd = get_words!();

    if cmd.is_empty() {
        return;
    }

    for command in COMMANDS.iter() {
        if command.name == cmd[0] {
            (command.function)(cmd);
            return;
        }
    }
}

fn echo(cmd: Vec<String>) {
    
    for col in 1..=cmd.len() - 1 {
        print!("{} ", cmd[col]);
    }
    println!();
}

fn help(cmd : Vec<String>) {
    println!();
    for command in COMMANDS.iter() {
        print!("{}: ", command.name);
        println!("{}", command.description);
    }
}