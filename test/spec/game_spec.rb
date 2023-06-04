require "ship"
require "board"
require "player"
require "game"

RSpec.describe Game do
  before(:example) do
    @game = Game::Core.new
    @mock_game = instance_double(Game::Core)
  end

  describe Game::Core do

    describe "#start" do
      it "It starts the initialization loop and game loop and notify players" do
        # Infinite Loop
        # mock_players = Array.new(2) { instance_double(Player) }
        # mock_players.each { |x| allow(x).to receive(:win).and_return(0) }
        #
        # expect(@game).to receive(:message).ordered.with("Initializing Game")
        # expect(@game).to receive(:initialization_loop).ordered
        # expect(@game).to receive(:message).ordered.with("Start of the Game")
        # expect(@game).to receive(:game_loop).ordered
        # expect(@game).to receive(:players).ordered.and_return(mock_players)
        # expect(@game).to receive(:restart_loop).ordered.and_return(false)
        # allow(@game).to receive(:message)
        #
        # @game.start
      end

      context "One of the player has win #{Game::Core::NUMBER_OF_WIN}" do
        it "Should ends the loop" do
          mock_players = Array.new(2) { instance_double(Player) }
          mock_players.each { |x| allow(x).to receive(:win).and_return(Game::Core::NUMBER_OF_WIN) }

          expect(@game).to receive(:message).ordered.with("Initializing Game")
          expect(@game).to receive(:initialization_loop).once.ordered
          expect(@game).to receive(:message).ordered.with("Start of the Game")
          expect(@game).to receive(:game_loop).once.ordered
          expect(@game).to receive(:players).once.ordered.and_return(mock_players)
          expect(@game).to receive(:restart_loop).once.ordered.and_return(false)
          allow(@game).to receive(:message)

          @game.start
        end
      end
    end

    describe "#initialize" do
      it "should start without player and running" do
        expect(@game.players).to eq([])
        expect(@game.current_state).to eq(:running)
      end
    end

    describe "#initialization_loop" do
      it "Should initialize players" do
        board = instance_double(Board)
        expect(board).to receive(:add_ship).exactly(4)

        player = instance_double(Player)
        expect(player).to receive("name").exactly(2).and_return("toto")
        expect(player).to receive("ships").exactly(4).and_return([])
        expect(player).to receive("board").exactly(4).and_return(board)

        expect(@game).to receive(:create_player).exactly(2).and_return(player)

        expect(@game).to receive(:create_ship_loop).exactly(4)
        expect(@game).to receive(:clear_console).exactly(2)
        expect(@game).to receive(:switch_players).exactly(2)

        # allow(@game).to receive(:create_player).exactly(2)
        @game.initialization_loop
      end

      context "players are already initialized when game is restarted" do
        before(:example) do
          @game.instance_variable_set("@players", Array.new(2) { instance_double(Player) })
          @game.players.each do |player|
            board = instance_double(Board)
            expect(board).to receive(:add_ship).exactly(2)

            expect(player).to receive("name").exactly(1).and_return("toto")
            expect(player).to receive("ships").exactly(2).and_return([])
            expect(player).to receive("board").exactly(2).and_return(board)
          end
        end

        it "Should reset the players state" do
          @game.players.each do |player|
            expect(player).to receive(:reset).once
          end

          expect(@game).to receive(:message).exactly(2)
          expect(@game).to receive(:create_ship_loop).exactly(4)
          expect(@game).to receive(:clear_console).exactly(2)
          # Note that stubbing this function make it hard to test method on player
          # expect(@game).to receive(:switch_players).exactly(2)

          @game.initialization_loop
        end
      end
    end

    describe "#create_player" do
      it "Should ask player name and create it" do
        expect(@game).to receive(:message).once.ordered.with("Enter player name:")
        expect(@game).to receive(:ask_player).once.ordered.and_return("toto")
        expect(@game).to receive(:message).once.ordered.with("\nHello toto\n")

        expect(@game.create_player).to be_an(Player)
      end
    end

    describe "#create_ship_loop" do
      before(:example) do
        @game.instance_variable_set("@players", Array.new(2) { Player.new("toto") })
      end

      it "Should create a ship with the given user input" do
        proto = { :size => 4 }
        allow(@game).to receive(:message)
        expect(@game).to receive(:ask_player).once.and_return("A0-6")

        expect(@game.create_ship_loop(proto)).to be_an(Ship)
      end
    end

    describe "#game_loop" do
      before(:example) do
        @game.instance_variable_set("@players", Array.new(2) { Player.new("toto") })
      end

      it "Switch turns between player and stop when a user win" do
        allow(@game).to receive(:message)
        expect(@game).to receive(:rand).and_return(0)

        expect(@game).to receive(:fire_loop).ordered
        expect(@game).to receive(:has_win?).ordered.and_return(false)
        expect(@game).to receive(:switch_players).ordered

        expect(@game).to receive(:fire_loop).ordered
        expect(@game).to receive(:has_win?).ordered.and_return(true)
        expect(@game).to receive(:switch_players).ordered

        @game.game_loop
        expect(@game.current_state).to eq(:stop)
      end

      it "Should select first user at random" do
        allow(@game).to receive(:message)

        expect(@game).to receive(:rand).and_return(1)
        expect(@game).to receive(:switch_players).ordered

        expect(@game).to receive(:fire_loop).ordered
        expect(@game).to receive(:has_win?).ordered.and_return(false)
        expect(@game).to receive(:switch_players).ordered

        expect(@game).to receive(:fire_loop).ordered
        expect(@game).to receive(:has_win?).ordered.and_return(true)
        expect(@game).to receive(:switch_players).ordered

        @game.game_loop
        expect(@game.current_state).to eq(:stop)
      end

      context "Restart call" do
        before(:example) do
          @game.instance_variable_set("@current_state", :restart)
        end

        it "Should restart the initialization / game loop" do
          # Note that call from test count as 1
          expect(@game).to receive(:rand).and_return(0)
          expect(@game).to receive(:start).once

          @game.game_loop
        end
      end
    end

    describe "#fire_loop" do
      before(:example) do
        @game.instance_variable_set("@players", Array.new(2) { Player.new("toto") })
        # Add default ship to opponent board
        ship = Ship.new({ x: 0, y: 0 }, 4, 0)
        ship.build_parts(@game.opponent.board)
        @game.opponent.board.add_ship(ship)

        @player_input = "A0"
      end

      it "Should ask coordinates and respond to what happened on position" do
        allow(@game).to receive(:message)
        expect(@game).to receive(:ask_player).once.and_return(@player_input)
        expect(@game).to receive(:message).once.with("- You hit a Ship !")
        expect(@game.player).to receive(:reset_miss).once

        @game.fire_loop
      end

      context "Miss fire" do
        before(:example) do
          @player_input = "A4"
        end

        it "Should show player miss message" do
          allow(@game).to receive(:message)
          expect(@game).to receive(:ask_player).once.and_return(@player_input)
          expect(@game.player).to receive(:add_miss).once
          expect(@game).to receive(:message).once.with("- You miss !")

          @game.fire_loop
        end
      end

      context "Sank boat" do
        before(:example) do
          # Hit the other parts of the ship
          @game.opponent.board.get_cell({ x: 0, y: 0 }).check
          @game.opponent.board.get_cell({ x: 1, y: 0 }).check
          @game.opponent.board.get_cell({ x: 2, y: 0 }).check

          @player_input = "A3"
        end

        it "Should show player sank message" do
          allow(@game).to receive(:message)
          expect(@game).to receive(:ask_player).once.and_return(@player_input)
          expect(@game).to receive(:message).once.with("- The Ship has sank !")
          expect(@game.player).to receive(:reset_miss).once

          @game.fire_loop
        end
      end

      context "Restart call" do
        before(:example) do
          @game.instance_variable_set("@current_state", :restart)
        end

        it "Should skip the fire loop" do
          expect(@game).to_not receive(:ask_player)
          @game.fire_loop
        end
      end
    end

    describe "#restart_loop" do

      it "Should restart game" do
        expect(@game).to receive(:ask_player).and_return("yes")

        expect(@game.restart_loop).to eq(true)
      end

      it "Should end the game" do
        expect(@game).to receive(:ask_player).and_return("no")

        expect(@game.restart_loop).to eq(false)
      end
    end

    describe "#show_hint" do
      before(:example) do
        @mock_board = instance_double(Board)
        @mock_player = instance_double(Player)
      end

      it "Display secret information to player about opponent" do
        allow(@game).to receive(:message)
        expect(@game).to receive(:to_display_coordinate).once
        expect(@game).to receive(:opponent).once.and_return(@mock_player)
        expect(@mock_player).to receive(:board).once.and_return(@mock_board)
        expect(@mock_board).to receive(:get_hint).once.and_return({ x: 0, y: 0 })

        @game.show_hint
      end
    end

    describe "#has_win?" do
      before(:example) do
        @game.instance_variable_set("@players", [Array.new(2) { instance_double(Player) }])
        @game.players.each { |x| allow(x).to receive(:name) }
      end

      it "Should be false while opponent did not loose" do
        expect(@game.opponent).to receive(:loose?).once.and_return(false)
        expect(@game.has_win?).to eq(false)
      end

      context "opponent has lost" do
        before(:example) do
          expect(@game.opponent).to receive(:loose?).once.and_return(true)
        end

        it "Should be a win for player" do
          expect(@game.has_win?).to eq(true)
        end
      end
    end

    describe "#switch_players" do
      before(:example) do
        @game.instance_variable_set("@players", [Array.new(2) { instance_double(Player) }])
      end

      it "Should invert the player order" do
        expect(@game.players).to receive(:reverse!).once
        @game.switch_players
      end
    end

    describe "#player" do
      before(:example) do
        @game.instance_variable_set("@players", [Array.new(2) { instance_double(Player) }])
      end

      it "Should always be the first player" do
        player = @game.players.first

        expect(@game.player).to eq(player)
      end
    end

    describe "#opponent" do
      before(:example) do
        @game.instance_variable_set("@players", [Array.new(2) { instance_double(Player) }])
      end

      it "Should always be the second player" do
        player = @game.players.last

        expect(@game.opponent).to eq(player)
      end
    end

    describe "#quit" do
      it "Should change current_state" do
        expect(@game.current_state).to eq(:running)
        @game.quit
        expect(@game.current_state).to eq(:stop)
      end
    end

    describe "#draw" do
      before(:example) do
        @game.instance_variable_set("@players", [instance_double(Player)])
        @game.players.each { |x| x.instance_variable_set("@board", instance_double(Board)) }
      end

      it "Should Draw the board of each players" do
        @game.players.each do |player|
          expect(player).to receive(:to_s).once.and_return("toto")
          expect(player).to receive(:board).once.and_return(player.instance_variable_get("@board"))
          expect(player.instance_variable_get("@board")).to receive(:draw).once.and_return("Nothing")
        end

        @game.draw
      end
    end

    describe "#restart" do
      it "Should change current_state" do
        expect(@game.current_state).to eq(:running)
        @game.restart
        expect(@game.current_state).to eq(:restart)
      end
    end
  end

  describe Game::IO do
    # TODO
    describe "#ask_player" do

      it "Should ask player to enter a value in console" do

      end

      it "Should catch Keywords" do

      end
    end

    # TODO
    describe "#message" do
      it "Show a message in the STDOUT" do

      end
    end

    # TODO
    describe "#error_message" do
      it "Encapsulate message into a visible banner" do

      end
    end

    describe "#parse_coordinate" do
      context "Coordinates mnust have been validated by #valid_coordinate_input?" do
        it "Transform valid string input coordinate into board coordinates" do
          expect(@game.parse_coordinate("a0")).to eq({ x: 0, y: 0 })
          expect(@game.parse_coordinate("b1")).to eq({ x: 1, y: 1 })
          expect(@game.parse_coordinate("c2")).to eq({ x: 2, y: 2 })
          expect(@game.parse_coordinate("d3")).to eq({ x: 3, y: 3 })
          expect(@game.parse_coordinate("e4")).to eq({ x: 4, y: 4 })

          expect(@game.parse_coordinate("a0")).to eq({ x: 0, y: 0 })
          expect(@game.parse_coordinate("a1")).to eq({ x: 1, y: 0 })
          expect(@game.parse_coordinate("a2")).to eq({ x: 2, y: 0 })
          expect(@game.parse_coordinate("a3")).to eq({ x: 3, y: 0 })
          expect(@game.parse_coordinate("a4")).to eq({ x: 4, y: 0 })

          expect(@game.parse_coordinate("a0")).to eq({ x: 0, y: 0 })
          expect(@game.parse_coordinate("b0")).to eq({ x: 0, y: 1 })
          expect(@game.parse_coordinate("c0")).to eq({ x: 0, y: 2 })
          expect(@game.parse_coordinate("d0")).to eq({ x: 0, y: 3 })
          expect(@game.parse_coordinate("e0")).to eq({ x: 0, y: 4 })
        end

        it "Only take the first two chars of coordinate" do
          expect(@game.parse_coordinate("a10")).to eq({ x: 1, y: 0 })
        end
      end
    end

    describe "#to_display_coordinate" do
      it "transform Board coordinates into display coordinates" do
        expect(@game.to_display_coordinate({ x: 0, y: 0 })).to eq("A0")
        expect(@game.to_display_coordinate({ x: 0, y: 1 })).to eq("B0")
        expect(@game.to_display_coordinate({ x: 1, y: 1 })).to eq("B1")
      end
    end

    describe "#parse_restart" do
      it "Should only be true for #{Game::IO::TRUE_WORD}" do
        alpha = ('a'..'z').to_a
        100.times do
          x = (rand(2) + 1).times.map { alpha[rand(alpha.size)] }.join
          next if (Game::IO::TRUE_WORD).include?(x)
          expect(@game.parse_restart(x)).to eq(false)
        end
      end
    end

    describe "#valid_restart_input" do
      it "Should only accept #{(Game::IO::FALSE_WORD + Game::IO::TRUE_WORD).inspect}" do
        (Game::IO::FALSE_WORD + Game::IO::TRUE_WORD).each do |x|
          expect(@game.valid_restart_input?(x)).to eq(true)
        end
      end

      it "Should should fail otherwise" do
        alpha = ('a'..'z').to_a
        100.times do
          x = (rand(2) + 1).times.map { alpha[rand(alpha.size)] }.join
          next if (Game::IO::FALSE_WORD + Game::IO::TRUE_WORD).include?(x)
          expect(@game.valid_restart_input?(x)).to eq(false)
        end
      end
    end

    describe "#valid_orientation_input?" do
      it "Cannot accept nil value" do
        expect(@game.valid_orientation_input?(nil)).to eq(false)
      end

      it "Should be one of the numeric keys pad (excluding 5)" do
        Game::IO::MAP_KEY_ORIENTATION.keys.each do |x|
          expect(@game.valid_orientation_input?(x)).to eq(true)
        end
      end
    end

    describe "#valid_coordinate_input?" do
      it "Cannot accept nil value" do
        expect(@game.valid_coordinate_input?(nil)).to eq(false)
      end

      it "Should have at least 2 chars" do
        ('a'..'z').each do |letter|
          expect(@game.valid_coordinate_input?(letter)).to eq(false)
        end

        (0..9).each do |number|
          expect(@game.valid_coordinate_input?(number)).to eq(false)
        end
      end

      it "Should have a number as second char" do
        ('a'..'z').each do |letter|
          ('a'..'z').each do |number|
            expect(@game.valid_coordinate_input?(letter + number)).to eq(false)
          end
        end
      end

      it "Should start by a letter (defined in the Board) and finish by a number" do
        Board::ALPHABET.each do |letter|
          (0..9).each do |number|
            expect(@game.valid_coordinate_input?("#{letter}#{number}")).to eq(true)
          end
        end
      end
    end
  end
end