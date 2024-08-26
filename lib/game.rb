# frozen_string_literal: true

require_relative 'board'
require_relative 'computer_player'

# Game class.
class Game
  def initialize
    @user_score = 0
    @computer_score = 0
    @computer_player = ComputerPlayer.new
  end

  def start
    welcome
    @num_of_rounds = rounds

    puts

    play
  end

  def display_board(msg: nil)
    # system('clear') || system('cls')
    puts "\nCodeBreaker - The Ultimate Mastermind Game\n\n"

    puts "#{msg}\n\n" if msg
    board.display

    puts "Code maker's secret: #{board.reveal_secret_code}\n\n" if @code_maker == 'human'
  end

  private

  attr_reader :board, :num_of_rounds, :computer_player

  def play
    num_of_rounds.times do
      interim_questions

      play_round

      puts "The secret code was: #{board.reveal_secret_code}\n\n"
    end
  end

  def play_round
    while board.moves_used < Board.moves_allowed
      puts @player_reference

      guess = if @code_maker == 'human'
                sleep(0.15)
                computer_player.make_guess
              else
                input
              end

      begin
        board.add_guess(guess:)
      rescue SecretCodeError
        error = "Your guess #{guess} has invalid colors: Try again".colorize(:red)
      end

      display_board(msg: error) if @code_maker == 'human'

      msg = move_feedback
      display_board(msg:)

      if board.code_broken?
        announce_winner
        break
      end
    end
  end

  def move_feedback
    if @code_maker == 'human'
      begin
        feedback = input(prompt: 'Provide feedback for move: ~> ')
        raise ArgumentError if feedback.empty?

        board.provide_feedback(feedback:)
      rescue ArgumentError
        move_feedback
      end
      computer_player.process_feedback(feedback)
    else
      board.provide_feedback
    end

    'Code master provided feedback'.colorize(:green)
  end

  def announce_winner
    puts 'Hurray, the secret code was cracked'
  end

  def prepare_board(option)
    if option == 1
      @player_reference = "Computer's move: Thinking..."
      @code_maker = 'human'
      Board.new(secret: user_secret)
    elsif option == 2
      @player_reference = 'Your move: make a guess.'
      @code_maker = 'computer'
      Board.new(auto: true)
    end
  end

  def welcome
    puts 'Welcome to CodeBreaker - The Ultimate Mastermind Game'
    puts
  end

  def user_secret
    puts "\nYou've chosen to be the code maker. Now choose your secret"
    puts 'This is the list of available colors: ' \
           "#{Board.allowed_colors}\n\n"

    puts 'Specify only the first letters of the color you want to use'
    puts 'Example: ymbr. This will select Yellow, Magenta, Blue and Red'

    input
  end

  def input(prompt: '~>: ')
    print prompt

    begin
      gets.chomp
    rescue Interrupt, NoMethodError
      puts "Exited\n"
      exit(1)
    end
  end

  def interim_questions
    puts 'Do you want to be the code maker or code breaker?'
    puts '[1]. Code Maker'
    puts '[2]. Code Breaker'
    puts '[0]. Quit'

    option = input.to_i

    exit if option.zero?

    puts
    @board = prepare_board(option)
    start if board.nil?
  end

  def rounds
    puts 'How many rounds should the game have?'
    puts 'Note: The player with the score at the end of the rounds wins'

    begin
      Integer(input)
    rescue ArgumentError, NoMethodError
      puts "\nExpected an integer value. Try again\n".colorize(:red)
      rounds
    end
  end
end
