# This is the main graphing class used for generating svg graphs.
#
# :author: Christopher Giroir <kelsin@valefor.com>

require 'color'

class Lilygraph
  # Default options for the initializer
  DEFAULT_OPTIONS = {
    :height => '100%',
    :width => '100%',
    :indent => 2,
    :padding => 14,
    :bar_text => true,
    :viewbox => {
      :width => 800,
      :height => 600
    },
    :margin => { :top => 50, :left => 50, :right => 50, :bottom => 100 }
  }

  # An array of labels to use on the y axis. Make sure you have the right number
  # of labels. The size of this array should = the size of the data array.
  attr_accessor :labels

  # This is the data for the graph. It should be an array where every item is
  # either a number or an array of numbers.
  # 
  # Examples:
  # For a simple bar graph: data=[1,2,3]
  # For a grouped bar graph: data=[[1,10],[2,20],[3,30]]
  attr_accessor :data
  
  # Returns a new graph creator with some default options and other options that you pass.
  #
  # The options has includes:
  # :height - String to use as height parameter on the svg tag. Default is '100%'.
  # :width - String to use as width parameter on the svg tag. Default is '100%'.
  # :indent - Indent option to the XmlMarkup object. Defaults to 2.
  # :padding - Number of svg units in between two bars.
  # :viewbox - Hash of :height and :width keys to use for the viewbox parameter of the svg tag. Defaults to { :height => 600, :width => 800 }.
  # :margin - Hash of margins to use for graph (in svg units). Defaults to { :top => 50, :left => 50, :right => 50, :bottom => 100 }.
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @data = []
    @labels = []
  end

  # Updates the graph options with items from the passed in hash
  def update_options(options = {})
    @options = @options.merge(options)
  end

  # This returns a string of the graph as an svg. You can pass in a block in
  # order to add your own items to the graph. Your block is passed the XmlMarkup
  # object to use as well as the options hash in case you need to use some of
  # that data.
  def render
    output = ""
    xml = Builder::XmlMarkup.new(:target => output, :indent => @options[:indent])

    # Output headers unless we specified otherwise
    xml.instruct!
    xml.declare! :DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.1//EN", "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"

    xml.svg(:viewBox => "0 0 #{@options[:viewbox][:width]} #{@options[:viewbox][:height]}",
            :width => @options[:width], :height => @options[:height],
            :xmlns => 'http://www.w3.org/2000/svg', :version => '1.1') do |xml|

      xml.g(:fill => 'black', :stroke => 'black', 'stroke-width' => '2',
            'font-family' => 'Helvetica, Arial, sans-serif', 'font-size' => '10px', 'font-weight' => 'medium') do |xml|

        # Outline
        xml.rect(:x => @options[:margin][:left], :y => @options[:margin][:top],
                 :width => graph_width,
                 :height => graph_height,
                 :fill => 'lightgray')

        xml.g 'stroke-width' => '1' do |xml|

          # Title
          xml.text(@options[:title], 'font-size' => '24px', :x => (@options[:viewbox][:width] / 2.0).round, :y => (@options[:subtitle] ? 24 : 32), 'text-anchor' => 'middle') if @options[:title]
          xml.text(@options[:subtitle], 'font-size' => '18px', :x => (@options[:viewbox][:width] / 2.0).round, :y => 34, 'text-anchor' => 'middle') if @options[:subtitle]

          # Lines
          xml.g 'font-size' => '10px' do |xml|
            line_x1 = @options[:margin][:left] + 1
            line_x2 = @options[:viewbox][:width] - @options[:margin][:right] - 1

            text_x = @options[:margin][:left] - 25

            xml.text 0, :x => text_x, :y => (@options[:viewbox][:height] - @options[:margin][:bottom] + 4), 'stroke-width' => 0.5

            1.upto((max / 10) - 1) do |line_number|
              y = (@options[:margin][:top] + (line_number * dy)).round
              xml.line :x1 => line_x1, :y1 => y, :x2 => line_x2, :y2 => y, :stroke => '#666666'
              xml.text max - line_number * 10, :x => text_x, :y => y + 4, 'stroke-width' => 0.5

              # Smaller Line
              xml.line(:x1 => line_x1, :y1 => y + (0.5 * dy), :x2 => line_x2, :y2 => y + (0.5 * dy), :stroke => '#999999') if max < 55
            end

            xml.text max, :x => text_x, :y => @options[:margin][:top] + 4, 'stroke-width' => 0.5
            # Smaller Line
            xml.line(:x1 => line_x1, :y1 => @options[:margin][:top] + (0.5 * dy), :x2 => line_x2, :y2 => @options[:margin][:top] + (0.5 * dy), :stroke => '#999999') if max < 55
          end

          # Labels
          xml.g 'text-anchor' => 'end', 'font-size' => '12px', 'stroke-width' => 0.3 do |xml|
            @labels.each_with_index do |label, index|
              x = (@options[:margin][:left] + (dx * index) + (dx / 2.0)).round
              y = @options[:viewbox][:height] - @options[:margin][:bottom] + 15
              xml.text label, :x => x, :y => y, :transform => "rotate(-45 #{x} #{y})"
            end
          end

          # Bars
          xml.g 'font-size' => '8px', 'stroke-width' => 0.3 do |xml|
            @data.each_with_index do |data, data_index|
              data = Array(data)
              width = dx - @options[:padding]
              bar_width = (width / Float(data.size)).round

              x = (@options[:margin][:left] + (dx * data_index)).round

              # Rectangles
              data.each_with_index do |number, number_index|
                color = Color::HSL.from_fraction(data_index * (1.0 / @data.size),1.0, 0.4 + (number_index * 0.2)).to_rgb
                height = ((dy / 10.0) * number).round

                bar_x = (x + ((dx - width) / 2.0) + (number_index * bar_width)).round
                bar_y = @options[:viewbox][:height] - @options[:margin][:bottom] - height

                xml.rect :fill => color.html, :stroke => color.html, 'stroke-width' => 0, :x => bar_x, :width => bar_width, :y => bar_y, :height => height - 1
              end

              # Text
              if @options[:bar_text]
                data.each_with_index do |number, number_index|
                  height = ((dy / 10.0) * number).round

                  bar_x = (x + ((dx - width) / 2.0) + (number_index * bar_width)).round
                  text_x = (bar_x + (bar_width / 2.0)).round

                  bar_y = @options[:viewbox][:height] - @options[:margin][:bottom] - height
                  text_y = bar_y - 3

                  xml.text number, :x => text_x, :y => text_y, 'text-anchor' => 'middle'
                end
              end
            end
          end

          # Yield in case they want to do some custom drawing and have a block ready
          yield xml, @options if block_given?

        end
      end
    end

    output
  end

  private

  def max
    ((((@data.map do |num|
          num.respond_to?(:max) ? num.max : num
        end.max || 0) + 5) / 10.0).ceil * 10).round
  end

  def graph_height
    @options[:viewbox][:height] - (@options[:margin][:top] + @options[:margin][:bottom])
  end

  def graph_width
    @options[:viewbox][:width] - (@options[:margin][:left] + @options[:margin][:right])
  end

  def number_of_slots
    @data.size
  end

  def dx
    graph_height / Float(number_of_slots)
  end

  def dy
    (graph_width * 10.0) / Float(max)
  end
end
