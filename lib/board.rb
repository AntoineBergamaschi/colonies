# frozen_string_literal: true

class Board
  HEIGHT = 5
  WIDTH = 5
  ALPHABET = ('a'..("a"..'z').to_a[HEIGHT-1]).to_a

  attr_reader :cells

  def initialize
    @cells = Array.new(HEIGHT*WIDTH){ Cell.new }
  end

  class Cell
    attr_accessor :checked, :ship_part

    def initialize
      @checked = false
      @ship_part = nil
    end

    def check
      @checked = true
      if @ship_part
        # Fire touch a Ship
        @ship_part.hit = true
      end

      return nil
    end

    # X Ship is hit
    # O Intact Ship part
    # _ Missed fire
    # . Empty Cell
    # @return [String] Symbol formatted Cell value
    def to_s
      return "X" if @checked && @ship_part && @ship_part.hit
      return "O" if @ship_part
      return "_" if @checked
      return "."
    end

    def reset
      @checked = false
      @ship_part = nil
    end
  end

  # @param position [Numeric] Position in one dimension Array
  # @return [Hash] {:x, :y} coordinates
  def self.to_coordinate(position)
    return { x: position.to_i % WIDTH, y: position.to_i / WIDTH }
  end

  # @param coordinates [Hash] {:x, :y} coordinates
  # @return [Integer] Position in one dimension Array
  def self.to_position(coordinates)
    coordinates[:x] + coordinates[:y] * WIDTH
  end

  # @param position [Numeric, Hash] either a +position+ or +coordinates+
  # @return [Boolean]
  def self.inside?(position)
    if position.is_a?(Hash) && [:x, :y].all? { |x| position.keys.include?(x) }
      return position[:x] >= 0 && position[:y] >= 0 && position[:x] < WIDTH && position[:y] < HEIGHT
    elsif position.is_a?(Numeric)
      return inside?(to_coordinate(position))
    end

    return false
  end

  # @param ship [Ship]
  def add_ship(ship)
    ship.parts.each do |part|
      cells[part.position].ship_part = part
    end;nil
  end

  # @param ships [Enumerable<Ship>]
  def add_ships(ships)
    ships.each { |ship| add_ship(ship) };nil
  end

  # @param coordinates [Hash] {:x, :y} coordinates
  # @return [Cell, nil] Nil if the position does not exist or the coordinates are outside of the board
  def get_cell(coordinates)
    return nil if !Board.inside?(coordinates)
    return @cells[Board.to_position(coordinates)]
  end

  def reset
    @cells.each{|x| x.reset };nil
  end

  def draw
    (0...Board::HEIGHT).each do |i|
      print @cells[(i * Board::WIDTH)...((i + 1) * Board::WIDTH)].map{|x| x.to_s}.inspect
      print "\n"
    end;nil
  end
end