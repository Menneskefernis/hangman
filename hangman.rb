require 'colorize'
require 'msgpack'

class Game
  attr_accessor :words, :current_word, :guess_state, :attempts_left, :end_game
  
  def initialize
    @words = dictionary
    @current_word = random_word
    @guess_state = initialize_guess_string
    @attempts_left = 8
    @end_game = false
  end

  def start    
    puts "Welcome to a game of Hangman!"
    puts "You can save your progress any time by typing" + " save".green + "."
    puts ""
    request_old_game unless Dir["./save_files/*.dat"].size == 0
 
    #puts current_word

    until end_game || attempts_left < 1
      play_round
    end
  end

  def play_round
    puts ""
    puts "What's your guess? Enter a letter from a-z."
    puts ""
    show_guess_state
    puts ""
    input = get_input do |input|
              break input if (input =~ /[A-Za-z]/ && input.size == 1) || input == "save"
              puts "Enter ONE letter"
            end

    if input == "save"
      handle_save
    else
      check_guess(input)
    end
  end

  def handle_save
    puts "What name would you like to use for your save file?"
    
    input = gets.chomp
    Dir.mkdir('./save_files') unless Dir.exist?('./save_files')
    to_msgpack(input)
    self.end_game = true
  end

  def request_old_game
    puts "Would you like to load an old game? (y/n)".light_blue
    
    get_input do |input|
      if input == "y" || input == "n"
        handle_game_load if input == "y"
        break
      else
        puts "Enter 'y' or 'n'."
      end
    end
  end

  def handle_game_load
    puts "Which game would you like to load?"
    puts ""

    files = Dir["./save_files/*.dat"]
    list_savegames(files)

    input = ""
    loop do
      input = gets.chomp.to_i
      break if (1 .. files.size).include?(input)
      puts "Enter a file number."
    end

    from_msgpack(files[input - 1])
  end

  def list_savegames(files)
    i = 1
    
    files.each do |f|
      filename = f.split('/').last
      puts i.to_s + ": " + filename
      i += 1
    end
  end

  def dictionary
    File.readlines('dictionary.txt')
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
    self.end_game = true
    puts ""
    puts "You guessed the right word: " + current_word.upcase.green
  end

  def lose
    puts ""
    puts "You are out of attempts. The word was #{current_word.upcase}!".red
    puts "The man was hung!"
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
    words.select { |word| word.size > 5 && word.size <= 12 }.sample.strip.downcase
  end

  def get_input    
    input = nil
    
    loop do
      input = gets.chomp.downcase
      yield(input)      
    end
  end

  def to_msgpack(filename)
    data = {
      current_word: current_word.strip,
      guess_state: guess_state.strip,
      attempts_left: attempts_left
    }.to_msgpack

    File.open("./save_files/#{filename}.dat", 'w') { |file| file.write data}
  end

  def from_msgpack(file)
    data = File.read(file)
    
    obj = MessagePack.unpack(data)
    
    self.current_word = obj['current_word']
    self.guess_state = obj['guess_state']
    self.attempts_left = obj['attempts_left']
    
    puts "Your data has been loaded."
  end
end

hangman = Game.new
hangman.start