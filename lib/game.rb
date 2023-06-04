# frozen_string_literal: true
require "#{__dir__}/board"
require "#{__dir__}/player"
require "#{__dir__}/ship"

module Game
  module IO
    # Map between numeric pad keys and actual radian orientation
    MAP_KEY_ORIENTATION = {
      "6" => 0,
      "9" => Math::PI / 4,
      "8" => Math::PI / 2,
      "7" => 3 * Math::PI / 4,
      "4" => Math::PI,
      "1" => 5 * Math::PI / 4,
      "2" => 3 * Math::PI / 2,
      "3" => 7 * Math::PI / 4,
    }

    KEY_WORD = ["quit", "restart", "draw", "player"]
    TRUE_WORD = ["yes", "y", "t"]
    FALSE_WORD = ["n", "no", "f"]

    # @return [String] The line of text entered in the console
    def ask_player
      print "-> "
      response = STDIN.readline.strip

      if KEY_WORD.include?(response.downcase)
        self.send(response.downcase).to_s if self.respond_to?(response.downcase)
        return ""
      end

      return response
    end

    def message(message)
      STDOUT.puts message
    end

    def error_message(message)
      STDERR.puts "\n" + ("#" * 80)
      STDERR.puts message
      STDERR.puts "#" * 80 + "\n\n"
    end

    def clear_console
      STDOUT.puts "\n" * 5
    end

    # Expect a String of form [aA-zZ][0-9]
    # @example
    #   "a1", "A9", ...
    # @param str_coordinates [String]
    # @return [Hash] {x: Integer, y: Integer} pair of coordinates
    def parse_coordinate(str_coordinates)
      coordinate = {}
      coordinate[:x] = str_coordinates[1].to_i
      coordinate[:y] = Board::ALPHABET.index(str_coordinates[0].to_s)
      return coordinate
    end

    # @param keycode [String, #to_s]
    # @return [Boolean]
    def parse_restart(str)
      return TRUE_WORD.include?(str.to_s.downcase)
    end

    # @param keycode [String, #to_s]
    # @return [Boolean]
    def valid_restart_input?(str)
      return (FALSE_WORD + TRUE_WORD).include?(str.to_s.downcase)
    end

    # @param keycode [String, #to_s]
    # @return [Boolean] True if the given input can be transformed to coordinate
    def valid_orientation_input?(keycode)
      return false if keycode.nil?
      return false if MAP_KEY_ORIENTATION[keycode.to_s].nil?
      return true
    end

    # @param str_coordinates [String, #to_s]
    # @return [Boolean] True if the given input can be transformed to coordinate
    def valid_coordinate_input?(str_coordinates)
      return false if str_coordinates.nil?

      str_coordinates = str_coordinates.to_s

      # First value must be a Letter included in the board Alphabet
      return false if Board::ALPHABET.index(str_coordinates[0]).nil?
      # Second value must be an Integer [0-9]
      return false if str_coordinates[1] != str_coordinates[1].to_i.to_s

      return true
    end
  end

  class Core
    attr_reader :players, :current_state
    attr_reader :debug

    include Game::IO

    STATES = {
      :restart => false,
      :stop => false,
      :running => true,
    }

    NUMBER_OF_PLAYER = 2

    def initialize
      @players = []
      @current_state = :running
    end

    # Starts the BattleShipGame
    # The game ends when a winner is decided, Ie when a player has all his ships sank.
    # @param options [Hash]
    # @option options []
    def start(options = {})
      @current_state = :running

      message "Initializing Game"
      initialization_loop

      message "Start of the Game"
      game_loop

      if restart_loop
        @current_state = :restart
        start
      end

      return nil
    end

    # Game setup loop (Game cannot be quit at this step)
    # Initialize players and ships
    def initialization_loop
      if @players.size == 0
        NUMBER_OF_PLAYER.times do |i|
          @players << create_player
        end
      else
        @players.each do |player|
          player.reset
        end
      end

      NUMBER_OF_PLAYER.times do |i|
        message "\n* Player #{player.name} its time to create ships!"
        # TODO set const for ship prototypes
        # Ships to add
        [{ size: 4 }, { size: 3 }].each do |proto_ship|
          ship = create_ship_loop(proto_ship)
          # Add each player ship on the other player board
          player.ships << ship
          player.board.add_ship(ship)
        end

        # Clean console avoid other player to see ship location
        clear_console

        # Switch players so that first/last player are diff between loops
        switch_players
      end
    end

    def create_player
      message "Enter player name:"
      name = ask_player

      player = Player.new(name)
      message "\nHello #{player.name}\n"

      return player
    end

    # Initialize ships
    # @param proto_ship [Hash] The Default ship parameters (size cannot be defined by players)
    def create_ship_loop(proto_ship)
      ship = nil

      while true
        message "* Add a #{proto_ship[:size]} tile long ship"
        message "* Choose coordinates and orientation [#{Board::ALPHABET.first.upcase}-#{Board::ALPHABET.last.upcase}][0-#{Board::WIDTH - 1}]-[orientation]"
        message "\n[orientation] -> One of the number on the numeric keypad ( excluding 5 )"
        message "example : "
        message "\tA0-6 to build a ship starting at A0 and ending at A3"
        message "\tA0-3 to build a ship starting at A0 and ending at D3"
        str_coordinate, orientation_keycode = ask_player.split("-").map { |x| x.downcase.strip }

        if !valid_coordinate_input?(str_coordinate)
          error_message "Malformed coordinate"
          next
        end

        coordinate = parse_coordinate(str_coordinate)
        if !Board.inside?(coordinate)
          error_message "Coordinate outside of the board"
          next
        end

        if !valid_orientation_input?(orientation_keycode)
          error_message "Orientation is not valid choose in #{MAP_KEY_ORIENTATION.keys.inspect}"
          next
        end
        orientation = MAP_KEY_ORIENTATION[orientation_keycode]

        ship = Ship.new(coordinate, proto_ship[:size], orientation)
        # Parts are build on the second player board
        if !ship.build_parts(player.board)
          error_message "Cannot Build the ship on this location (either out off the board or over another ship)"
          next
        end

        break
      end

      return ship
    end

    # Main game loop
    # Each turn both players fire at each other
    # First player to sank all of the other player ships wins
    def game_loop
      # Select player at random
      rand(10).to_i.times { switch_players }

      while STATES[@current_state]
        message "-" * 6
        message "#{player.name} turn"

        fire_loop

        # Games continues while there is no victory
        @current_state = :stop if has_win?

        # Invert first and last player
        switch_players
      end

      if @current_state == :restart
        start()
      end
    end

    # Loop used to catch the coordinated the current will fire at
    def fire_loop
      while STATES[@current_state]
        message "* Choose coordinates [A-E][0-4] :"
        str_coordinate = ask_player.downcase
        if !valid_coordinate_input?(str_coordinate)
          error_message "Malformed coordinate"
          next
        end

        coordinate = parse_coordinate(str_coordinate)
        if !Board.inside?(coordinate)
          error_message "Coordinate outside of the board"
          next
        end

        cell = opponent.board.get_cell(coordinate)
        if cell.checked
          error_message "This cell |#{str_coordinate}| as already been fired at"
          next
        end

        cell.check
        if cell.ship_part
          message "- You hit a Ship !"
          if cell.ship_part.ship.sank?
            message "- The Ship has sank !"
          end
        else
          message "- You miss !"
        end

        # End of the loop
        break
      end
    end

    def restart_loop
      while true
        message "* Restart [Y/*]:"

        response = ask_player
        next if !valid_restart_input?(response)

        response = parse_restart(response)

        return response
      end
    end

    # @return [Boolean] True if the -first- player win the game
    def has_win?
      if opponent.loose?
        message "#{opponent.name} has lost all its ships"
        message "#{player.name} is Victorious"
        return true
      end

      return false
    end

    # Inverse #player / #opponent position
    # @return [nil] Nothing
    def switch_players
      @players.reverse!
      return nil
    end

    # First player in #players is the one currently playing (firing or creating ship)
    # @return [Player]
    def player
      @players.first
    end

    # Second/Last player in #players is the opponent of the +player+ (fire at)
    # @return [Player]
    def opponent
      @players.last
    end

    def quit
      @current_state = :stop
    end

    # Draw both player board
    def draw
      @players.each do |player|
        puts "Player #{player.to_s}"
        player.board.draw
      end
    end

    # Restart game ( keep both player )
    def restart
      @current_state = :restart
    end
  end
end

