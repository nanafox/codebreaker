# CodeBreaker - A Mastermind CLI Game

This is a simple implementation of the classic board game Mastermind. The game is played in the
command line interface (CLI) and is written in Ruby.

## Pre-requisites

- Ruby 3.x.x

## Installation

1. Clone the repository

    ```bash
    git clone https://github.com/nanafox/codebreaker.git
    ```
2. Change into the directory

    ```bash
    cd codebreaker
    ```

3. Install the dependencies

    ```bash
    bundle install
    ```

4. Run the game

    ```bash
    ruby codebreaker.rb
    ```
5. Follow the instructions to play the game.

## Features

- The game generates a random code of 4 colors from a pool of 6 colors.
- The player has 12 attempts to guess the code.
- The player can choose to play as the code maker or code breaker.
- The player can choose to play again after the game ends.
- The game displays feedback after each guess.
