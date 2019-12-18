require 'colorize'

class Game
  attr_accessor :words, :current_word, :guess_state, :attempts_left
  
  def initialize
    @words = ["paper", "winter", "bicycle", "truck", "garbage", "chess"]
    @current_word = random_word
    @guess_state = initialize_guess_string
    @attempts_left = 4
  end

  def start
    #puts current_word

    while guess_state.include?("_") && attempts_left > 0
      play_round
    end
  end

  def play_round
    puts ""
    puts "Make a guess"
    puts ""
    show_guess_state
    input = get_input
    check_guess(input)
  end

  def initialize_guess_string
    str = ""
    (current_word.size).times { str += "_" }
    str
  end

  def show_guess_state
    puts guess_state.gsub('', ' ').upcase
  end

  def check_guess(input)
    if current_word.include?(input)
      set_guessed_letters(input)
    else
      self.attempts_left -= 1
      puts ""
      puts "Wrong guess! Attempts left: " + attempts_left.to_s.red
    end

    win unless guess_state.include?("_")
    lose if attempts_left == 0
  end

  def set_guessed_letters(input)
    positions = (0 ... current_word.length).find_all { |i| current_word[i] == input }

    positions.each do |pos|
      guess_state[pos] = input
    end
  end

  def win
    puts ""
    puts "You guessed the right word: " + current_word.upcase.green
  end

  def lose
    puts ""
    puts "You are out of attempts. The man was hung!".red
    puts ""
    puts " |     |"
    puts " |     |"
    puts " |     |"
    puts " |     |"
    puts "_|_____|_"
    puts "\\       /"
    puts " \\__|__/"
    puts ""
  end

  def random_word
    words.sample
  end

  def get_input    
    input = nil
    
    loop do
      input = gets.chomp.downcase

      if input =~ /[A-Za-z]/ && input.size == 1
        return input
      else
        puts "Enter ONE letter".red
      end
    end
  end

end

hangman = Game.new
hangman.start