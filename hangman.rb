class Game
  attr_accessor :words, :current_word, :guess_state
  
  def initialize
    @words = ["paper", "winter", "bicycle", "truck", "garbage", "chess"]
    @current_word = random_word
    @guess_state = initialize_guess_string
  end

  def start
    puts current_word
    
    while guess_state.include?("_")
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
    puts guess_state.gsub('', ' ')
  end

  def check_guess(input)
    if current_word.include?(input)
      positions = (0 ... current_word.length).find_all { |i| current_word[i] == input }

      positions.each do |pos|
        guess_state[pos] = input
      end
    end
    show_guess_state
  end

  def random_word
    words.sample
  end

  def get_input
    gets.chomp.downcase
  end
end

hangman = Game.new
hangman.start