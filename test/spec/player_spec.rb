require "ship"
require "board"
require "player"

RSpec.describe Player do
  before(:example) do
    @player = Player.new("toto")
  end

  describe "#initialize" do
    it "should be empty" do
      expect(@player.ships).to eq([])
      expect(@player.board.cells.map { |x| x.checked || !x.ship_part.nil? }.uniq).to eq([false])
    end
  end

  describe "#reset" do
    before(:example) do
      @player.instance_variable_set("@board", instance_double(Board))
      @player.instance_variable_set("@ships", Array.new(2) { instance_double(Ship) })
    end

    it "should clear the ships array and reset the board" do
      expect(@player.ships).to receive(:clear).once
      expect(@player.board).to receive(:reset).once
      @player.reset
    end
  end

  describe "#loose?" do
    before(:example) do
      @player.instance_variable_set("@ships", Array.new(2) { instance_double(Ship) })
    end

    it "should be false while player has ships not sank" do
      expect(@player.ships.first).to receive(:sank?).once.and_return(false)
      expect(@player.loose?).to eq(false)
    end

    context "All ship are sank" do
      before(:example) do
        @player.ships.each { |x| expect(x).to receive(:sank?).once.and_return(true) }
      end

      it "should be true" do
        expect(@player.loose?).to eq(true)
      end
    end
  end

  describe "#to_s" do
    it "should be player name" do
      expect(@player.to_s).to eq("toto")
    end
  end
end