# frozen_string_literal: true

require 'colorize'

# Exception class for secret code error
class SecretCodeError < StandardError
  def initialize(msg = 'The secret code provided does meet the requirements')
    super
  end
end

# Board helper
module BoardHelper
  CHECK_MARK = "\u2713".colorize(:green)
  WARNING_SIGN = "\u26a0".colorize(:yellow)
  MOVES_HOLDER = "\u00b0".colorize(:light_black) # Adjusted color symbol from :ash to :light_black
end

# rubocop:disable Metrics/ClassLength

# Board class
class Board
  @moves_allowed = 12
  include BoardHelper

  attr_reader :board, :moves_used

  class << self
    attr_reader :moves_allowed

    # Return all the allowed colors for the game.
    def allowed_colors
      colors.values.map { |color| color.to_s.colorize(color) }.join(', ')
    end

    private

    def colors
      @colors ||= {
        r: :red, y: :yellow, b: :blue, g: :green, m: :magenta, c: :cyan
      }
    end

    # Verify that the code master's secret is valid
    def valid_secret?(secret:)
      return false unless secret.is_a?(String) && secret.length == 4

      secret.chars.all? { |char| colors.key?(char.to_sym) }
    end
  end

  # Initialize a new board object
  def initialize(secret: '', auto: false)
    @secret_code = generate_secret_code(secret:, auto:)
    @board = generate_board
    @moves_used = 0
  end

  # Check if the code maker's secret has been broken.
  def code_broken?
    @correct_placements == secret_code.length
  end

  # Reveals the secret code in a colorized manner
  def reveal_secret_code
    secret_code.map { |code| code.to_s.colorize(code) }.join(', ')
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  # Display the board
  def display
    puts '   Moves     | Feedback'
    puts " #{'-' * 22} "

    board.each do |row|
      print '|'
      row[0, 4].each do |codebreaker_move|
        print " #{add_color(codebreaker_move)} "
      end
      print '| '
      row[4..].each do |code_maker_suggestions|
        print "#{code_maker_suggestions} "
      end
      puts '|'
    end
    puts " #{'-' * 22} "
  end

  # Updates the feedback section of the board with feedback for the current guess.
  # This method generates feedback for the most recent guess and updates the board.
  # It creates an array of feedback symbols, then randomly samples 4 of these symbols
  # to update the feedback section of the board.
  #
  # The feedback symbols are determined as follows:
  # - If the color in the guess matches the color and position in the secret
  # code, a check mark is added.
  # - If the color in the guess is present in the secret code but in a
  # different position, a warning sign is added.
  # - If the color in the guess is not present in the secret code,
  # a placeholder symbol is added.
  #
  # @note This method assumes that the board has been initialized and
  # that a guess has been made.
  # @note The feedback symbols are randomly sampled to add an element
  # of unpredictability.
  #
  # @example
  #   # Assuming the board has been initialized and a guess has been made:
  #   board.provide_feedback
  #   # The feedback section of the board is updated with feedback symbols.
  def provide_feedback(feedback: '')
    if feedback.empty?
      board[@moves_used - 1][4..] = generate_feedback.sample(4)
    else
      feedback.chars.each_with_index do |char, index|
        case char
          when 'w'
            board[@moves_used - 1][4 + index] = WARNING_SIGN
          when 'b'
            board[@moves_used - 1][4 + index] = CHECK_MARK
          when '.'
            board[@moves_used - 1][4 + index] = MOVES_HOLDER
          else
            raise ArgumentError, "Feedback should only include '.', 'w' and 'b'"
        end
      end
    end
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # Adds the code breaker's guess to the table and waits for feedback from
  # the code maker.
  def add_guess(guess:)
    raise SecretCodeError unless self.class.send(:valid_secret?, secret: guess)

    guess.chars.each_with_index do |char, index|
      board[@moves_used][index] = char
    end

    @moves_used += 1
  end

  # Generate the secret code maker
  def generate_secret_code(secret:, auto: false)
    return self.class.send(:colors).values.sample(4) if auto

    raise SecretCodeError unless self.class.send(:valid_secret?, secret:)

    secret.chars.map { |char| self.class.send(:colors)[char.to_sym] }
  end

  # Return the string representation of the board details.
  def to_s
    "Code maker secret: #{secret_code}"
  end

  private

  attr_reader :secret_code # the secret code is not visible from outside

  # Generate a new board for the mastermind game
  def generate_board
    Array.new(self.class.moves_allowed) do
      Array.new(8, MOVES_HOLDER)
    end
  end

  # Add a color to the move before display it
  def add_color(char)
    return char unless char.respond_to? :to_sym

    char.colorize(self.class.send(:colors)[char.to_sym])
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize

  def generate_feedback
    secret_copy = secret_code.dup
    move_colors = colors_from_move(board[@moves_used - 1][0, 4])

    if move_colors == secret_code
      @correct_placements = secret_code.length
      return board[@moves_used - 1][4..] = [CHECK_MARK] * 4
    end

    move_colors.each_with_index.map do |move, index|
      if move == secret_copy[index]
        secret_copy[index] = nil
        board[@moves_used - 1][4 + index] = CHECK_MARK

      elsif secret_copy.include?(move)
        secret_copy[secret_copy.index(move)] = nil
        board[@moves_used - 1][4 + index] = WARNING_SIGN

      else
        board[@moves_used - 1][4 + index] = MOVES_HOLDER
      end
    end

    board[@moves_used - 1][4..]
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def colors_from_move(move)
    if move.is_a? String
      move.chars.map { |char| self.class.send(:colors)[char.to_sym] }
    else
      move.map { |char| self.class.send(:colors)[char.to_sym] }
    end
  end
end

# rubocop:enable Metrics/ClassLength
