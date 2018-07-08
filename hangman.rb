require 'io/console'
require 'json'

$filename = "./5desk.txt"
$saved_game = "./saved_game.json"
class Hangman
  def initialize
    @word = random_word().downcase
    @guesses = ["a","e","i","o","u"]
    @count = 0
    puts "Enter 'n' to start new game, 's' to load saved game!"
    puts "Press 'Ctrl' + 's' any time to save and exit game."
    puts "Press 'Ctrl' + 'c' any time to quit without saving."
    while true
      input = STDIN.getch.downcase
      if input == 's'
        begin
          json = File.open($saved_game).readlines[0]
          puts json
          @word = JSON.parse(json)["word"]
          @guesses = JSON.parse(json)["guesses"]
          @count = JSON.parse(json)["count"]
          break
        rescue
          puts "No saved games! press 'n' to start a new game : "
        end
      elsif input == 'n'
        break
      else
        puts "Invalid input! enter 'n' or 's' only : "
      end
    end
    display()
    move()
  end

  def move
    if (@count >= 5 || @count < 0)
      puts "You lose ! The word was #{@word}!"
      return
    elsif check()
      puts "COngratulations ! You Win ! The word was #{@word}"
      return
    end
    puts "Your move : "
    input = STDIN.getch.downcase.ord
    if input == 19
      puts "Your game has been saved!"
      save_quit
      return
    elsif input == 3
      puts "Too dificult for you i see... The word was #{@word} !"
      return
    end
    if input.between?(97,122)
      if @guesses.include?(input.chr)
        puts "Already used, try a different letter !"
      else
        @guesses.push(input.chr)
        @count += 1 unless @word.include?(input.chr)
      end
    else
      puts "Invalid input!, try again :"
    end
    puts ""
    display()
    move()
  end

  def save_quit
    json = {
      "word" => @word,
      "guesses" => @guesses,
      "count" => @count
    }.to_json
    File.open($saved_game, "w") do |f|
      f.puts json
    end
    json
  end

  def display
    @word.split("").each {|l| print @guesses.include?(l) ? l : "_ "}
    puts ""
    puts "Used letters : #{@guesses.drop(5)}"
    puts "Chances left : #{6 - @count}"
  end

  def random_word
    words = []
    File.readlines($filename).each do |line|
      word = line.slice(/\w+/)
      words.push(word) if word.length.between?(5,12)
    end
    words[rand(words.length)]
  end

  def check
    @word.split("").each do |l|
      return false unless @guesses.include?(l)
    end
    return true
  end
end

game = Hangman.new
