# frozen_string_literal: true

class Player
  attr_reader :ships, :board, :name, :missed_fire, :win

  def initialize(name)
    @name = name
    @board = Board.new
    @ships = []
    @missed_fire = 0
    @win = 0
  end

  def reset
    @board.reset
    @ships.clear
    @missed_fire = 0
  end

  def add_win
    @win += 1
  end

  def add_miss
    @missed_fire += 1
  end

  def reset_miss
    @missed_fire = 0
  end

  def to_s
    return @name
  end

  def loose?
    return @ships.detect{|x| !x.sank? }.nil?
  end
end
