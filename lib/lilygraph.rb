# This is the main graphing class used for generating svg graphs.
#
# Author:: Christopher Giroir <kelsin@valefor.com>

require 'color'

# This is the main class to use if you want to create a graph!
#
#   graph = Lilygraph.new(:title => "My Awesome Graph")
#   graph.data = [1,2,3]
#   graph.labels = ['One','Two','Three']
#   graph.render
#
# This class outputs svg as a string once you call render.
class Lilygraph
  # Default options for the initializer
  DEFAULT_OPTIONS = {
    :height => '100%',
    :width => '100%',
    :indent => 2,
    :padding => 14,
    :legend => :right,
    :bar_text => :number,
    :type => :bar,
    :flush => false,
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
  # For a simple bar graph:
  #   graph.data=[1,2,3]
  # For a grouped bar graph:
  #   graph.data=[[1,10],[2,20],[3,30]]
  attr_accessor :data

  # This allows you to set colors for the bars.
  #
  # If you just want a single color:
  #   graph.colors='#0000aa'
  # If you want to make each bar (or bar group) different colors:
  #   graph.colors=['#aa0000','#00aa00','#0000aa']
  # If you want every bar group to be the same, but each bar in the groups to have a different color
  #   graph.colors=[['#aa0000','#00aa00','#0000aa']]
  # If you want to set every bar group color:
  #   graph.colors=[['#aa0000','#00aa00','#0000aa'],['#bb0000','#00bb00','#0000bb']]
  # Last but not least you can set the color value to any object that responds to call (like a Proc). The proc takes four arguments.
  # data_index: The index of the current bar (or group)
  # number_index: The index of the current bar INSIDE of the current bar group (always 0 if you don't have grouped bars)
  # data_size: total number of bar or groups.
  # number_size: total number of bars in the current group (always 1 if you don't have bar groups)
  #
  # The default proc looks like:
  #   graph.colors=Proc.new do |data_index, number_index, data_size, number_size|
  #     Color::HSL.from_fraction(Float(data_index) / Float(data_size), 1.0, 0.4 + (Float(number_index) / Float(number_size) * 0.4)).to_rgb.html
  #   end
  attr_accessor :colors

  # This allows you to make a legend for your graph. Just pass in a hash of
  # color => text pairs. Set to nil if you don't want a legend. No legend is the
  # default.
  #
  #   graph.legend = { '#ff0000' => 'Chris', '#00ff00' => 'Caitlin' }
  attr_accessor :legend

  # Returns a new graph creator with some default options specified via a hash:
  # height:: String to use as height parameter on the svg tag. Default is <tt>'100%'</tt>.
  # width:: String to use as width parameter on the svg tag. Default is <tt>'100%'</tt>.
  # indent:: Indent option to the XmlMarkup object. Defaults to <tt>2</tt>.
  # padding:: Number of svg units in between two bars. Defaults to <tt>14</tt>.
  # bar_text:: (Boolean) Whether or not to include the text labels above every bar. Defaults to +true+.
  # viewbox:: Hash of <tt>:height</tt> and <tt>:width</tt> keys to use for the viewbox parameter of the svg tag. Defaults to <tt>{:height => 600, :width => 800}</tt>.
  # margin:: Hash of margins to use for graph (in svg units). Defaults to <tt>{:top => 50, :left => 50, :right => 50, :bottom => 100}</tt>.
  #
  # For example, this creates a graph with a title and different indent setting:
  #
  #   graph = Lilygraph.new(:title => 'Testing a title', :indent => 4)
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @data = []
    @labels = []

    @legend = nil

    @colors = Proc.new do |data_index, number_index, data_size, number_size|
      Color::HSL.from_fraction(Float(data_index) / Float(data_size), 1.0, 0.4 + (Float(number_index) / Float(number_size) * 0.4)).html
    end
  end

  # Updates the graph options with items from the passed in hash. Please refer
  # to new for a description of available options.
  def update_options(options = {})
    @options = @options.merge(options)
  end

  # This returns a string of the graph as an svg. You can pass in a block in
  # order to add your own items to the graph. Your block is passed the XmlMarkup
  # object to use as well as the options hash in case you need to use some of
  # that data.
  #
  #   graph.render do |xml|
  #     xml.text "Hello", :x => 5, :y => 25
  #   end
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

            text_x = @options[:margin][:left] - 5

            xml.text 0, :x => text_x, :y => (@options[:viewbox][:height] - @options[:margin][:bottom] + 4), 'stroke-width' => 0.5, 'text-anchor' => 'end'

            1.upto((max / division) - 1) do |line_number|
              y = (@options[:margin][:top] + (line_number * dy)).round
              xml.line :x1 => line_x1, :y1 => y, :x2 => line_x2, :y2 => y, :stroke => '#666666'
              xml.text max - line_number * division, :x => text_x, :y => y + 4, 'stroke-width' => 0.5, 'text-anchor' => 'end'

              # Smaller Line
              xml.line(:x1 => line_x1, :y1 => y + (0.5 * dy), :x2 => line_x2, :y2 => y + (0.5 * dy), :stroke => '#999999') if max < 55
            end

            xml.text max, :x => text_x, :y => @options[:margin][:top] + 4, 'stroke-width' => 0.5, 'text-anchor' => 'end'
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
          xml.g 'font-size' => '10px', 'stroke-width' => 0.3 do |xml|
            last_spot = []

            @data.each_with_index do |data, data_index|
              data = Array(data)
              width = dx - @options[:padding]
              bar_width = (width / Float(data.size)).round

              x = (@options[:margin][:left] + (dx * data_index)).round

              # Rectangles
              data.each_with_index do |number, number_index|
                color = if @colors.respond_to? :call
                          @colors.call(data_index, number_index, @data.size, data.size)
                        elsif @colors.class == Array
                          first = @colors[data_index % (@colors.size)]

                          if first.class == Array
                            first[number_index % (first.size)]
                          else
                            first
                          end
                        else
                          @colors
                        end

                height = ((dy / division) * number).round

                bar_x = (x + ((dx - width) / 2.0) + (number_index * bar_width)).round
                bar_y = @options[:viewbox][:height] - @options[:margin][:bottom] - height


                case @options[:type]
                when :bar then
                  xml.rect :fill => color, :stroke => color, 'stroke-width' => 0, :x => bar_x, :width => bar_width, :y => bar_y, :height => height - 1
                when :line then
                  if last_spot[number_index]
                    xml.line(:x1 => last_spot[number_index][:x], :y1 => last_spot[number_index][:y], :x2 => bar_x, :y2 => bar_y,
                             :fill => color, :stroke => color, 'stroke-width' => 2.0)
                  end
                  xml.circle :cx => bar_x, :cy => bar_y, :fill => color, :stroke => color, :r => bar_width * 1.5
                end

                last_spot[number_index] = { :x => bar_x, :y => bar_y }
              end
            end

            @data.each_with_index do |data, data_index|
              data = Array(data)
              width = dx - @options[:padding]
              bar_width = (width / Float(data.size)).round

              x = (@options[:margin][:left] + (dx * data_index)).round

              # Text
              if @options[:bar_text] != :none
                last_bar_height = false
                data.each_with_index do |number, number_index|
                  percent_total = data.inject(0) { |total, percent_number| total + percent_number }

                  if number > 0
                    height = ((dy / division) * number).round

                    bar_x = (x + ((dx - width) / 2.0) + (number_index * bar_width)).round
                    text_x = (bar_x + (bar_width / 2.0)).round

                    bar_y = @options[:viewbox][:height] - @options[:margin][:bottom] - height
                    text_y = bar_y - 3

                    if last_bar_height && (last_bar_height - height).abs < 14
                      text_y -= (14 - (height - last_bar_height))
                      last_bar_height = false
                    else
                      last_bar_height = height
                    end

                    label = case @options[:bar_text]
                            when :number then number
                            when :percent then (100.0 * Float(number) / Float(percent_total)).round.to_s + "%"
                            end

                    xml.text label, :x => text_x, :y => text_y, 'text-anchor' => 'middle'
                  else
                    last_bar_height = false
                  end
                end
              end
            end
          end

          # Legend
          if @legend
            if @options[:legend] == :right
              legend_x = @options[:viewbox][:width] - (3 * @options[:margin][:right])
            else
              legend_x = (@options[:margin][:left] * 1.5).round
            end
            legend_y = (@options[:margin][:top] / 2) + @options[:margin][:top]
            xml.rect :fill => '#ffffff', :stroke => '#000000', 'stroke-width' => 2, :x => legend_x, :y => legend_y, :width => (2.5 * @options[:margin][:right]), :height => (@legend.size * 15) + 16

            @legend.sort.each_with_index do |data, index|
              color, label = data
              xml.rect :fill => color, :stroke => color, 'stroke-width' => 0, :x => legend_x + 10, :y => legend_y + 10 + (index * 15), :width => 35, :height => 10
              xml.text label, :x => legend_x + 55, :y => legend_y + 18 + (index * 15), 'text-anchor' => 'left'
            end
          end

          # Yield in case they want to do some custom drawing and have a block ready
          yield(xml, @options) if block_given?

        end
      end
    end

    output
  end

  private

  def data_max
    [@data.map do |num|
       num.respond_to?(:max) ? num.max : num
     end.max || 1, 1].max
  end

  def division
    [(10 ** Math.log10(data_max).floor), 1].max
  end

  def max
    if @options[:flush]
      temp_max = data_max
    else
      temp_max = (data_max + [division / 10, 1].max)
    end

    ((temp_max / Float(division)).ceil * Float(division)).round      
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
    graph_width / Float(number_of_slots)
  end

  def dy
    (graph_height * division) / Float(max)
  end
end
