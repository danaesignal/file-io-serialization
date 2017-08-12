require "yaml"

class HangmanGame
  def initialize
    @dictionary_source = File.open("5desk.txt", "r")
    @game_dictionary = @dictionary_source.readlines
    @dictionary_source.close
    @min_length = 5
    @max_length = 12
    @winner = nil
    @guesses_left = 7
    @player_progress = []
    @incorrect_guesses = []

    pick_word
    pregaming
  end

  #This method handles saving a game to a YAML file.
  def save_game
    saved_state = {
      guesses_left: @guesses_left,
      player_progress: @player_progress,
      incorrect_guesses: @incorrect_guesses,
      current_word: @current_word
    }

    File.open("saved_game.yml", "w") {|f| f.write(saved_state.to_yaml)}
  end

  #This method handles loading a game from a YAML file.
  def load_game
    load_state = YAML.load(File.open("saved_game.yml"))

    @guesses_left = load_state[:guesses_left]
    @player_progress = load_state[:player_progress]
    @incorrect_guesses = load_state[:incorrect_guesses]
    @current_word = load_state[:current_word]
  end

  #Picks a word from the current dictionary
  #The word is rejected/repicked if it's outside the current size specification
  def pick_word
    @current_word = @game_dictionary.sample
    until @current_word.length.between?(@min_length, @max_length) do
      @current_word = @game_dictionary.sample
    end
    @current_word.chomp!.downcase!
    @current_word = @current_word.split("")

    @current_word.length.times {|i| @player_progress[i] = "_"}
  end

  #This is the logic for checking a player's guesses
  #and handling the consequences of those guesses.
  def check_guess(player_guess)
    if @current_word.include?(player_guess)
      puts "Correct!"
      @current_word.each_with_index do |letter, i|
        if letter == player_guess
          @player_progress[i] = @current_word[i]
        end
      end
    elsif player_guess == "-" || player_guess == "."
      puts "Game saved."
      save_game
      abort if player_guess == "."
    else
      puts "Wrong!"
      @incorrect_guesses.push(player_guess)
      @guesses_left -= 1
    end
  end

  #This logic determines if the game is over and if the player won.
  #"Never Be Game Over" - Liquid "Plumber" Snake, 1980s, probably
  def check_game_over
    if @guesses_left <= 0
      @winner = false
      true
    elsif @player_progress == @current_word
      @winner = true
      true
    end
  end

  #This handles user input and determines if they're putting in a single letter
  def take_guess
    guess = gets.chomp.downcase
    while guess.length != 1
      puts "Please only enter a single letter at a time."
      guess = gets.chomp.downcase
    end
    return guess
  end

  #This handles displaying the correct game over message.
  def toast
    case @winner
    when true
      puts "You won! The word was #{@current_word.join("")}!"
    when false
      puts "You lost! The word was #{@current_word.join("")}."
    end
  end

  #This handles introductions and allows the user to load a saved game or start a new one
  def pregaming
    puts "We're playing Hangman."
    puts "Do you want to start a new game, or continue from a saved game?"
    puts "[new/load]"
    @user_input == ""
    until @user_input == "load" || @user_input == "new"
      @user_input = gets.chomp
      case @user_input
      when "load"
        load_game if File.exist?("saved_game.yml")
        puts "No saved game found! Starting new game." unless File.exist?("saved_game.yml")
        play_game
      when "new"
        play_game
      else
        puts "I'm sorry, I didn't understand that."
      end
    end
  end

  #This is the main method that handles player input and calls other game methods
  def play_game
    while @winner == nil
      puts "Here's your current progress: #{@player_progress.join(" ")}"
      puts "You have #{@guesses_left} incorrect guesses left."
      puts "Your incorrect guesses are: #{@incorrect_guesses.join(" ")}"
      puts "Make a guess, type - to save, or . to save and exit."
      check_guess(take_guess)
      break if check_game_over == true
    end
    toast
  end
end

new_game = HangmanGame.new
