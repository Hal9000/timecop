class ClockTime
  
  attr_reader :hour, :min, :sec

  def initialize(*args)
p *args
    case args.size
      when 1  # should be a String or Time
        t = args.first
puts "found: #{t} (#{t.class})"
        raise ArgumentError unless [String, Time].include? t.class
        t = Time.parse(t) if t.is_a? String # now it's a Time
        h, m, s = t.hour, t.min, t.sec
        @hour, @min, @sec = h, m, s
      when 3  # should be three ints
        h, m, s = *args
        @hour, @min, @sec = h, m, s
      else
        raise "ClockTime: can't parse args #{args}"
    end
  end

  def inspect
    "#@hour:#@min:#@sec"
  end

  def to_yaml_properties
    ["@hour","@min","@sec"]
  end

end

