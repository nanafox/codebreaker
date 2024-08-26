#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/board'
require_relative 'lib/game'

def main
  game = Game.new

  game.start
end

main if __FILE__ == $PROGRAM_NAME
