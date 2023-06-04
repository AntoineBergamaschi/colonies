# frozen_string_literal: true

class Player
  attr_reader :ships, :board, :name

  def initialize(name)
    @name = name
    @board = Board.new
    @ships = []
  end

  def reset
    @board.reset
    @ships.clear
  end

  def to_s
    return @name
  end

  def loose?
    return @ships.detect{|x| !x.sank? }.nil?
  end
end
