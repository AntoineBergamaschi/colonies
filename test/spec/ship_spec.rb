require "ship"
require "board"

RSpec.describe Ship do
  before(:context) do
    @orientations = (0...(2 * Math::PI)).step(Math::PI / 4)
  end
  # Create a Default ship with basic parameters
  before(:example) do
    @ship = Ship.new({ :y => 0, :x => 0 }, Board::WIDTH, 0)
  end

  describe "#direction" do
    before(:example) do
      # Rotation matrix for each value of +@orientations+
      @rotation_matrix = [{ :x => 1.0, :y => 0.0 },
                          { :x => 1.0, :y => 1.0 },
                          { :x => 0.0, :y => 1.0 },
                          { :x => -1.0, :y => 1.0 },
                          { :x => -1.0, :y => 0.0 },
                          { :x => -1.0, :y => -1.0 },
                          { :x => 0.0, :y => -1.0 },
                          { :x => 1.0, :y => -1.0 }]
    end

    it 'should match the PI/4 increment rotation matrix' do
      expect(@orientations.map { |orientation| @ship.send(:direction, orientation) }).to eq(@rotation_matrix)
    end
  end

  describe "#build_parts" do
    before(:example) do
      @mock_board = instance_double(Board)
      @board = Board.new
    end

    it 'Should call get_cell from Board to place cells' do
      [{ :x => 0, :y => 0 }, { :x => 1, :y => 0 },
       { :x => 2, :y => 0 }, { :x => 3, :y => 0 },
       { :x => 4, :y => 0 }].each do |coordinates|
        expect(@mock_board).to receive(:get_cell).once.ordered.with(coordinates).and_return(Board::Cell.new)
      end

      expect(@ship.build_parts(@mock_board)).to eq(true)
    end

    context "For orientaion = 0" do
      before(:example) do
        #   Do noting orientation is already 0 be default
      end

      (0...Board::HEIGHT).to_a.each do |y|
        context "For position x:0 y:#{y}" do
          before(:example) do
            @ship.instance_variable_set("@coordinate", { x: 0, y: y })
          end

          it 'Should place parts correctly' do
            expect(@ship.build_parts(@board)).to eq(true)

            positions = [{ :x => 0, :y => y }, { :x => 1, :y => y },
                         { :x => 2, :y => y }, { :x => 3, :y => y },
                         { :x => 4, :y => y }].map { |x| Board.to_position(x) }

            # Verify parts position
            expect(@ship.parts.map { |p| p.position }).to eq(positions)
          end
        end

        (1...Board::WIDTH).to_a.each do |x|
          context "For position x:#{x} y:#{y}" do
            before(:example) do
              @ship.instance_variable_set("@coordinate", { x: x, y: y })
            end

            it 'exceed the board range' do
              expect(@ship.build_parts(@board)).to eq(false)
            end
          end
        end
      end
    end

    context "For orientaion = PI/2" do
      before(:example) do
        @ship.instance_variable_set("@orientation", Math::PI / 2)
      end

      (0...Board::WIDTH).to_a.each do |x|
        context "For position x:#{x} y:0" do
          before(:example) do
            @ship.instance_variable_set("@coordinate", { x: x, y: 0 })
          end

          it 'Should place parts correctly' do
            expect(@ship.build_parts(@board)).to eq(true)

            positions = [{ :x => x, :y => 0 }, { :x => x, :y => 1 },
                         { :x => x, :y => 2 }, { :x => x, :y => 3 },
                         { :x => x, :y => 4 }].map { |x| Board.to_position(x) }


            # Verify parts position
            expect(@ship.parts.map { |p| p.position }).to eq(positions)
          end
        end

        (1..Board::HEIGHT).to_a.each do |y|
          context "For position x:#{x} y:#{y}" do
            before(:example) do
              @ship.instance_variable_set("@coordinate", { x: x, y: y })
            end

            it 'exceed the board range' do
              expect(@ship.build_parts(@board)).to eq(false)
            end
          end
        end
      end
    end

    context "For orientaion = PI" do
      before(:example) do
        @ship.instance_variable_set("@orientation", Math::PI)
      end

      (0...Board::HEIGHT).to_a.each do |y|
        context "For position x:4 y:#{y}" do
          before(:example) do
            @ship.instance_variable_set("@coordinate", { x: 4, y: y })
          end

          it 'Should place parts correctly' do
            expect(@ship.build_parts(@board)).to eq(true)

            positions = [{ :x => 4, :y => y }, { :x => 3, :y => y },
                         { :x => 2, :y => y }, { :x => 1, :y => y },
                         { :x => 0, :y => y }].map { |x| Board.to_position(x) }

            # Verify parts position
            expect(@ship.parts.map { |p| p.position }).to eq(positions)
          end
        end

        (0...(Board::WIDTH - 1)).to_a.each do |x|
          context "For position x:#{x} y:#{y}" do
            before(:example) do
              @ship.instance_variable_set("@coordinate", { x: x, y: y })
            end

            it 'exceed the board range' do
              expect(@ship.build_parts(@board)).to eq(false)
            end
          end
        end
      end
    end

    context "For orientaion = 3*PI/2" do
      before(:example) do
        @ship.instance_variable_set("@orientation", 3*Math::PI / 2)
      end

      (0...Board::WIDTH).to_a.each do |x|
        context "For position x:#{x} y:0" do
          before(:example) do
            @ship.instance_variable_set("@coordinate", { x: x, y: 4 })
          end

          it 'Should place parts correctly' do
            expect(@ship.build_parts(@board)).to eq(true)

            positions = [{ :x => x, :y => 4 }, { :x => x, :y => 3 },
                         { :x => x, :y => 2 }, { :x => x, :y => 1 },
                         { :x => x, :y => 0 }].map { |x| Board.to_position(x) }

            # Verify parts position
            expect(@ship.parts.map { |p| p.position }).to eq(positions)
          end
        end

        (0...(Board::HEIGHT - 1)).to_a.each do |y|
          context "For position x:#{x} y:#{y}" do
            before(:example) do
              @ship.instance_variable_set("@coordinate", { x: x, y: y })
            end

            it 'exceed the board range' do
              expect(@ship.build_parts(@board)).to eq(false)
            end
          end
        end
      end
    end

    context "For orientaion = PI/4" do
      before(:example) do
        @ship.instance_variable_set("@orientation", Math::PI / 4)
      end

      context "For position x:0 y:0" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 0, y: 0 })
        end

        it 'Should place parts correctly' do
          expect(@ship.build_parts(@board)).to eq(true)

          positions = [{ :x => 0, :y => 0 }, { :x => 1, :y => 1 },
                       { :x => 2, :y => 2 }, { :x => 3, :y => 3 },
                       { :x => 4, :y => 4 }].map { |x| Board.to_position(x) }

          # Verify parts position
          expect(@ship.parts.map { |p| p.position }).to eq(positions)
        end
      end

      context "For position x:1 y:0" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 1, y: 0 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end

      context "For position x:0 y:1" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 0, y: 1 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end
    end

    context "For orientaion = 3*PI/4" do
      before(:example) do
        @ship.instance_variable_set("@orientation", 3*Math::PI / 4)
      end

      context "For position x:4 y:0" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 4, y: 0 })
        end

        it 'Should place parts correctly' do
          expect(@ship.build_parts(@board)).to eq(true)

          positions = [{ :x => 4, :y => 0 }, { :x => 3, :y => 1 },
                       { :x => 2, :y => 2 }, { :x => 1, :y => 3 },
                       { :x => 0, :y => 4 }].map { |x| Board.to_position(x) }

          # Verify parts position
          expect(@ship.parts.map { |p| p.position }).to eq(positions)
        end
      end

      context "For position x:4 y:1" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 4, y: 1 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end

      context "For position x:3 y:1" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 3, y: 0 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end
    end

    context "For orientaion = 5*PI/4" do
      before(:example) do
        @ship.instance_variable_set("@orientation", 5*Math::PI / 4)
      end

      context "For position x:4 y:4" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 4, y: 4 })
        end

        it 'Should place parts correctly' do
          expect(@ship.build_parts(@board)).to eq(true)

          positions = [{ :x => 4, :y => 4 }, { :x => 3, :y => 3 },
                       { :x => 2, :y => 2 }, { :x => 1, :y => 1 },
                       { :x => 0, :y => 0 }].map { |x| Board.to_position(x) }

          # Verify parts position
          expect(@ship.parts.map { |p| p.position }).to eq(positions)
        end
      end

      context "For position x:4 y:3" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 4, y: 3 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end

      context "For position x:3 y:4" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 3, y: 4 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end
    end

    context "For orientaion = 7*PI/4" do
      before(:example) do
        @ship.instance_variable_set("@orientation", 7*Math::PI / 4)
      end

      context "For position x:0 y:4" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 0, y: 4 })
        end

        it 'Should place parts correctly' do
          expect(@ship.build_parts(@board)).to eq(true)

          positions = [{ :x => 0, :y => 4 }, { :x => 1, :y => 3 },
                       { :x => 2, :y => 2 }, { :x => 3, :y => 1 },
                       { :x => 4, :y => 0 }].map { |x| Board.to_position(x) }

          # Verify parts position
          expect(@ship.parts.map { |p| p.position }).to eq(positions)
        end
      end

      context "For position x:0 y:3" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 0, y: 3 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end

      context "For position x:3 y:0" do
        before(:example) do
          @ship.instance_variable_set("@coordinate", { x: 1, y: 4 })
        end

        it 'exceed the board range' do
          expect(@ship.build_parts(@board)).to eq(false)
        end
      end
    end
  end

  describe "#sank?" do
    before(:example) do
      @board = Board.new
      @ship.build_parts(@board)
    end

    it "has part style intact" do
      expect(@ship.sank?).to eq(false)
    end

    context "Ship had been fired on" do
      before(:example) do
        raise "Cannot test if ship as less to 1 part" if @ship.parts.size < 1
        @ship.parts.first.hit = true
      end

      it "should not have sank" do
        expect(@ship.sank?).to eq(false)
      end
    end

    context "Every parts of the ship have been hit" do
      before(:example) do
        @ship.parts.each{|p| p.hit = true}
      end

      it "should sank now" do
        expect(@ship.sank?).to eq(true)
      end
    end
  end
end