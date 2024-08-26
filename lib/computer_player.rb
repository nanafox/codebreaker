# frozen_string_literal: true

# Class for the computer player
class ComputerPlayer
  attr_reader :possible_codes, :current_guess

  def initialize
    @possible_codes = generate_all_possible_codes
    @current_guess = %i[r r y y] # Initial guess as per Knuth's algorithm
  end

  # Generate all possible codes for the game
  def generate_all_possible_codes
    colors = %i[r y b g m c]
    colors.repeated_permutation(4).to_a
  end

  # Make a guess based on the current guess
  def make_guess
    current_guess.join
  end

  def process_feedback(feedback)
    # If feedback contains '.', filter it out since it's optional
    filtered_feedback = feedback.gsub('.', '')

    # Only filter possible codes based on the feedback provided
    @possible_codes.select! do |code|
      generate_feedback(code, current_guess) == filtered_feedback
    end

    # Make a new guess from the filtered possible codes
    @current_guess = @possible_codes.sample
  end

  private

  # Generates feedback in the form of check marks and warning signs based on the guess and code
  def generate_feedback(code, guess)
    feedback = []

    # Count exact matches for feedback
    guess.each_with_index do |color, index|
      if color == code[index]
        feedback << 'b' # Correct color and position
      elsif code.include?(color)
        feedback << 'w' # Correct color, wrong position
      end
    end

    # Create a string of feedback
    feedback.join
  end
end
