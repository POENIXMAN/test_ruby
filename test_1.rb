require 'net/http'
require 'json'

class Cargo
  attr_reader :weight, :length, :width, :height, :distance, :price

  def initialize(weight, length, width, height, origin, destination)
    @weight = weight
    @length = length
    @width = width
    @height = height
    @origin = origin
    @destination = destination
    @distance = calculate_distance
    @price = calculate_price
  end

  def to_hash
    {
      weight: @weight,
      length: @length,
      width: @width,
      height: @height,
      distance: @distance,
      price: @price
    }
  end

  private

  def calculate_distance
    api_key = '8quYeGqhjxhIQ7ZekvDD6q8nm2ipZCLlQw7zXgwsbar0rgPHlCcOm2m9cloP8u2d'
    origins = @origin.split(',').map(&:strip).join(',')
    destinations = @destination.split(',').map(&:strip).join(',')
    url = URI("https://api.distancematrix.ai/maps/api/distancematrix/json?origins=#{origins}&destinations=#{destinations}&key=#{api_key}")
    
    begin
      response = Net::HTTP.get(url)
      result = JSON.parse(response)

      if result['rows'][0]['elements'][0]['status'] == 'OK'
        distance_in_meters = result['rows'][0]['elements'][0]['distance']['value']
        distance_in_kilometers = distance_in_meters / 1000.0
      else
        distance_in_kilometers = 0
      end

      distance_in_kilometers
    rescue SocketError => e
      puts "Network error: #{e.message}"
      0
    rescue JSON::ParserError => e
      puts "Error parsing response: #{e.message}"
      0
    end
  end

  def calculate_price
    volume = (@length * @width * @height) / 1_000_000.0

    if volume < 1
      @distance * 1
    elsif volume >= 1 && @weight <= 10
      @distance * 2
    else
      @distance * 3
    end
  end
end


# cargo = Cargo.new(15, 150, 150, 150, '51.4822656,-0.1933769', '51.4994794,-0.1269979')
# {:weight=>15.0, :length=>150.0, :width=>150.0, :height=>150.0, :distance=>6.56, :price=>19.68}


puts "Enter weight (kg):"
weight = gets.chomp.to_f
puts "Enter length (cm):"
length = gets.chomp.to_f
puts "Enter width (cm):"
width = gets.chomp.to_f
puts "Enter height (cm):"
height = gets.chomp.to_f
puts "Enter origin (latitude,longitude):"
origin = gets.chomp
puts "Enter destination (latitude,longitude):"
destination = gets.chomp

# Create cargo instance
cargo = Cargo.new(weight, length, width, height, origin, destination)
puts cargo.to_hash
