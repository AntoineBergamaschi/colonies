require "ship"
require "board"

RSpec.describe Board do
  before(:example) do
    @board = Board.new
  end

  describe "Coordinates / position manipulation" do
    it "change coordinates to position" do
      expect(Board.to_position({ x: 0, y: 0 })).to eq(0)
      expect(Board.to_position({ x: 4, y: 0 })).to eq(4)
      expect(Board.to_position({ x: 0, y: 4 })).to eq(20)
      expect(Board.to_position({ x: 4, y: 4 })).to eq(24)

      # Be aware that changing position doesn't mean keeping legal position
      expect(Board.to_position({ x: 100, y: 0 })).to eq(100)
      expect(Board.to_position({ x: 100, y: 100 })).to eq(600)
    end

    it "change position to coordinate" do
      expect(Board.to_coordinate(0)).to eq({ x: 0, y: 0 })
      expect(Board.to_coordinate(4)).to eq({ x: 4, y: 0 })
      expect(Board.to_coordinate(20)).to eq({ x: 0, y: 4 })
      expect(Board.to_coordinate(24)).to eq({ x: 4, y: 4 })

      # Be aware that changing position doesn't mean keeping legal position
      expect(Board.to_coordinate(100)).to eq({ x: 0, y: 20 })
      expect(Board.to_coordinate(600)).to eq({ x: 0, y: 120 })
    end

    context "is position inside board?" do
      it "should be inside the board" do
        (0...(Board::HEIGHT * Board::WIDTH) - 1).to_a.each do |pos|
          expect(Board.inside?(pos)).to eq(true)
        end
      end

      it "should be outside the board" do
        expect(Board.inside?(-1)).to eq(false)
        expect(Board.inside?(Board::HEIGHT * Board::WIDTH)).to eq(false)
      end
    end

    context "is coordinate inside board?" do
      it "should be inside the board" do
        (0...Board::WIDTH).to_a.each do |x|
          (0...Board::HEIGHT).to_a.each do |y|
            expect(Board.inside?({ :x => x, :y => y })).to eq(true)
          end
        end
      end

      it "should be outside" do
        expect(Board.inside?({ :x => -1, :y => 0 })).to eq(false)
        expect(Board.inside?({ :x => 0, :y => -1 })).to eq(false)
        expect(Board.inside?({ :x => Board::WIDTH, :y => 4 })).to eq(false)
        expect(Board.inside?({ :x => 4, :y => Board::HEIGHT })).to eq(false)
        expect(Board.inside?({ :x => Board::WIDTH, :y => Board::HEIGHT })).to eq(false)
      end
    end
  end

  describe "#reset" do
    before(:example) do
      @mock_cells = [instance_double(Board::Cell)]
      @board.instance_variable_set("@cells", @mock_cells)
    end

    it "Should reset cells" do
      @mock_cells.each { |x| expect(x).to receive(:reset).once }
      @board.reset
    end
  end

  describe "#draw" do
    before(:example) do
      @mock_cells = Array.new(Board::HEIGHT * Board::WIDTH) { instance_double(Board::Cell) }
      @board.instance_variable_set("@cells", @mock_cells)
    end

    it "Should reset cells" do
      @mock_cells.each { |x| expect(x).to receive(:to_s).once }
      @board.draw
    end
  end

  describe "#add_ship" do
    before(:example) do
      @mock_cells = Array.new(Board::HEIGHT * Board::WIDTH) { instance_double(Board::Cell) }
      @mock_ship = [instance_double(Ship)]
      @mock_parts = [instance_double(Ship::Part)]

      @board.instance_variable_set("@cells", @mock_cells)
    end

    it "Should Add ships parts to Cell" do
      @mock_ship.each_with_index { |x, i| expect(x).to receive(:parts).once.and_return(@mock_parts) }
      @mock_parts.each_with_index do |x, i|
        expect(x).to receive(:position).once.and_return(i)
        expect(@mock_cells[i]).to receive(:ship_part=).once
      end
      @board.add_ships(@mock_ship)
    end
  end

  describe "#add_ships" do
    before(:example) do
      @mock_cells = Array.new(Board::HEIGHT * Board::WIDTH) { instance_double(Board::Cell) }
      @mock_ship = [instance_double(Ship)]
      @mock_parts = [instance_double(Ship::Part)]

      @board.instance_variable_set("@cells", @mock_cells)
    end

    it "Should Add ships parts to Cell" do
      @mock_ship.each_with_index { |x, i| expect(x).to receive(:parts).once.and_return(@mock_parts) }
      @mock_parts.each_with_index do |x, i|
        expect(x).to receive(:position).once.and_return(i)
        expect(@mock_cells[i]).to receive(:ship_part=).once
      end
      @board.add_ships(@mock_ship)
    end
  end

  describe "#get_hint" do
    before(:example) do
      # Simulate a ship and checked position
      cell = @board.cells[0]
      cell.checked = true

      cell = @board.cells[1]
      cell.ship_part = true
    end

    it "Should return the coordinate of the checked position the closest to a ship part" do
      expect(@board.get_hint).to eq({x: 0, y: 0})
    end

    context "edge case" do
      before(:example) do
        # Simulate a ship and checked position
        cell = @board.cells[1]
        cell.checked = true

        cell = @board.cells[(Board::WIDTH*Board::HEIGHT)-1]
        cell.ship_part = true
      end

      it "Should return the coordinate of the checked position the closest to a ship part" do
        expect(@board.get_hint).to eq({x: 1, y: 0})

        # Change the Hint location
        cell = @board.cells[10]
        cell.checked = true

        expect(@board.get_hint).to eq({x: 0, y: 2})

        # Change the Hint location
        cell = @board.cells[14]
        cell.checked = true

        expect(@board.get_hint).to eq({x: 4, y: 2})

        # Change the Hint location
        cell = @board.cells[11]
        cell.ship_part = true

        expect(@board.get_hint).to eq({x: 0, y: 2})
      end
    end
  end
end