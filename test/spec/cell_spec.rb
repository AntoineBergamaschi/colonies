require "ship"
require "board"

RSpec.describe Board::Cell do
  before(:example) do
    @cell = Board::Cell.new
  end

  describe "#check" do
    it "should not be check" do
      expect(@cell.checked).to eq(false)
    end

    context "Player checked empty cell" do
      it "should have miss" do
        @cell.check

        expect(@cell.checked).to eq(true)
        expect(@cell.ship_part).to eq(nil)
      end
    end

    context "Player checked ship cell" do
      before(:example) do
        @cell.ship_part = instance_double(Ship::Part)
      end

      it "should have hit" do
        expect(@cell.ship_part).to receive(:hit=).once.with(true)
        @cell.check
        expect(@cell.checked).to eq(true)
      end
    end
  end

  describe "#to_s" do
    it "should be empty" do
      expect(@cell.to_s).to eq(".")
    end

    context "Checked by player" do
      before(:example) do
        @cell.instance_variable_set("@checked", true)
      end

      it "should be a miss" do
        expect(@cell.to_s).to eq("_")
      end
    end

    context "Cell containing a ship part" do
      before(:example) do
        @cell.instance_variable_set("@ship_part", instance_double(Ship::Part))
      end

      it "should be a ship part" do
        expect(@cell.to_s).to eq("O")
      end

      context "Checked by player" do
        before(:example) do
          @cell.instance_variable_set("@checked", true)
        end

        it "should be a hit ship" do
          expect(@cell.ship_part).to receive(:hit).and_return(true)
          expect(@cell.to_s).to eq("X")
        end
      end
    end
  end
end