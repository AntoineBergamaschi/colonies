# frozen_string_literal: true

class Ship
  attr_reader :parts, :coordinate, :size, :orientation

  class Part
    attr_accessor :hit
    attr_reader :position
    attr_reader :ship

    def initialize(position, ship)
      @position = position
      @hit = false
      @ship = ship
    end
  end

  def initialize(coordinate, size, orientation)
    @coordinate = coordinate
    @size = size
    @orientation = orientation
  end

  # @return [Boolean] True if all of the ship parts have been hit
  def sank?
    return parts.detect{|x| !x.hit }.nil?
  end

  def build_parts(board)
    increment = direction(@orientation)

    parts = []
    coordinate = {}
    # Construct the ship by parts
    @size.times do |i|

      coordinate[:x] = @coordinate[:x] + (increment[:x] * i)
      coordinate[:y] = @coordinate[:y] + (increment[:y] * i)

      # Verify that the cell exist and is empty
      cell = board.get_cell(coordinate)
      return false if cell.nil? || cell.ship_part

      parts << Part.new(Board.to_position(coordinate), self)
    end

    @parts = parts

    return true
  end

  private

  # @return [Hash] The direction coordinates (x, y), returned value are discrete for simplicity.
  def direction(orientation)
    # Grid Approximation always return a direction within the discrete values (-1, 0, 1)
    x = Math.cos(orientation).round(1)
    y = Math.sin(orientation).round(1)

    x /= x.abs if !x.zero?
    y /= y.abs if !y.zero?

    {x: x.to_i, y: y.to_i}
  end
end
