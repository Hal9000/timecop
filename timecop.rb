require 'date'
require 'yaml'
require 'storage'
require 'clocktime'

module Helpers

  def parsetime(time)
    nums = time.scan(/(\d{1,2}):(\d{2})(:\d{2})?/).flatten.map {|x| x.to_i }
    nums << 0 if nums.size==2
    ClockTime.new(*nums)
  end

  def weekday(date)
    days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    keys = days
    hash = {}
    days.each do |day|
      hash[day] = day                         # long str cap - Monday
      hash[day.downcase] = day                # long str low - monday
      hash[day.to_sym] = day                  # long sym cap - :Monday
      hash[day.downcase.to_sym] = day         # long sym low - :monday
      hash[day[0..2]] = day                   # abbr str cap - Mon
      hash[day.downcase[0..2]] = day          # abbr str low - mon
      hash[day[0..2].to_sym] = day            # abbr sym cap - :Mon
      hash[day[0..2].downcase.to_sym] = day   # abbr sym low - :mon
    end
    val = hash[date]
    return val unless val.nil?
    days[date.wday]
  end

  def interpret_time(time)
    result = case time
      when nil;       nil
      when Time;      ClockTime.new(time)
      when ClockTime; time
      when String;    parsetime(time)
      when DateTime;  raise "Can't handle DateTime yet"
      else
        raise ArgumentError
    end
  end

  def interpret_datetime(date,time)
    weekdays = %w[mon monday tue tuesday wed wednesday thu thursday
                  fri friday sat saturday sun sunday]
    key = date
    key = key.to_s.downcase if key.is_a? Symbol
    key = key.downcase if key.is_a? String
    part2 = interpret_time(time)
    part1 = case key
      when nil
        nil
      when "today"
        Date.today
      when "yesterday"
        Date.today - 1
      when "tomorrow"
        Date.today + 1
      when "daily"
        :daily           # silly hack?
      when *weekdays
        date             # return original string or sym
      when Date
        date
      when Time
        part2 ||= date   # time portion!
        Date.new(date.year, date.month, date.day)
      when String
        Date.parse(key)  # raise "Not implemented yet."
      else
        raise "Can't handle key '#{key}'"
    end
    [part1, part2]      # [date, time if any]
  end
end

#################

class TimeCop

  class << self
    attr_reader :store

    def open_store(dir="data")
      @store = Storage.new(dir)
    end

    def kill_store(dir, certain=false)
      `rm #{dir}/*` if certain
    end

    def load_store
      @store.load_all
    end
  end

end

###########

class Task

  include Helpers

  class << self
    include Helpers
    protected :new
  end

  attr_reader   :oid, :type

  # some accessors may be overridden
  
  attr_accessor :text, :date_due  
  attr_accessor :note, :completed

  def to_yaml_properties
    ["@oid","@type","@text","@date_due","@time_due","@completed","@note","@which_weeks"]
  end

  def initialize(type, text, date=nil, time=nil)
    @type = type
    @@store = TimeCop.store   # Just bring it in
    raise "Failed to call TimeCop.open_store" if @@store.nil?
    @text = String.new(text)   # calls to_str if it can
    @date_due, @time_due = interpret_datetime(date, time)
    @completed = false
    @deleted = false
    @modified = true   # About to save anyway
    @which_weeks = nil
    @oid = nil
    yield self if block_given?
    @oid = self.save
  end

  def to_s
    @text
  end

  def inspect
    "#{'%4d'%@oid}: #{'%-30s' % @text[0..29]}#{@text.size>30 ? '...' : '   '} (#@type)"
  end

  def match?(target)
    case @type 
      when :daily_task, :daily_appt, :daily_todo
        @target == @date_due
      when :weekly_task, :weekly_appt, :weekly_todo
        weekday(target) == @date_due  # day of week as string
      else
        false
    end
  end

  def modify(&block)
    @modified = true   # "dirty" - needs to be saved
    instance_eval(&block)
    save
    @modified = false  # all rather silly?
    self
  end

  # Unique...
  
  def self.create_task(text, date=nil, time=nil, &block)
    date, time = interpret_datetime(date, time)
    self.new(:task,text,date,time,&block)
  end

  def self.create_todo(text, &block)   # date/time not allowed
    self.new(:todo,text, &block)
  end

  def self.create_appt(text, date=:today, time=nil, &block)
    date, time = interpret_datetime(date, time)
    self.new(:appt,text,date,time,&block)
  end

  # Daily...

  def self.create_daily_task(text, time=nil, &block)
    time = interpret_time(time)
    self.new(:daily_task,text,:daily,time,&block)
  end

  def self.create_daily_todo(text, &block)
    time = interpret_time(time)
    self.new(:daily_todo,text,&block)
  end

  def self.create_daily_appt(text, time=nil, &block)
    time = interpret_time(time)
    self.new(:daily_appt,text,:daily,time,&block)
  end

  # Weekly...

  def self.create_weekly_task(text, day=:today, time=nil, &block)
    date, time = interpret_datetime(day, time)
    date = weekday(date) 
    self.new(:weekly_task,text,date,time,&block)
  end

  def self.create_weekly_todo(text, day=:today, &block)
    date, time = interpret_datetime(day, time)   # don't use time
    date = weekday(date)
    self.new(:weekly_todo,text,date,time,&block)
  end

  def self.create_weekly_appt(text, day=:today, time=nil, &block)
    date, time = interpret_datetime(day, time)
    date = weekday(date)
    self.new(:weekly_appt,text,date,time,&block)
  end

  # Monthly by day...
  
  def self.create_monthly_weekday_task(text, day=:today, *which_weeks, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    if which_weeks - [1,2,3,4,5] != []
      raise "Illegal set of weeks #{which_weeks.inspect}"
    end
    task = self.new(:monthly_weekday_task,text,date,nil,&block)
    task.modify { @which_weeks = which_weeks }
  end

  def self.create_monthly_weekday_todo(text, day=:today, *which_weeks, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    if which_weeks - [1,2,3,4,5] != []
      raise "Illegal set of weeks #{which_weeks.inspect}"
    end
    task = self.new(:monthly_weekday_todo,text,&block)
    task.modify { @which_weeks = which_weeks }
  end

  def self.create_monthly_weekday_appt(text, day=:today, *which_weeks, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    if which_weeks - [1,2,3,4,5] != []
      raise "Illegal set of weeks #{which_weeks.inspect}"
    end
    task = self.new(:monthly_weekday_appt,text,date,nil,&block)
    task.modify { @which_weeks = which_weeks }
  end

  # Monthly by date...

  def self.create_monthly_date_task(text, day=:today, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    self.new(:monthly_date_task,text,date,time,&block)
  end

  def self.create_monthly_date_appt(text, day=:today, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    self.new(:monthly_date_appt,text,date,time,&block)
  end

  def self.create_monthly_date_todo(text, day=:today, &block)
    date, time = interpret_datetime(day, time)  # ignore time
    self.new(:monthly_date_todo,text,date,time,&block)
  end

  def self.read(oid)
    @@store.read(oid)
  end

  def save
    @oid = @@store.save(self)  # return id
  end

  def delete
    @deleted = true
    @@store.delete(@oid)
  end

  def mark_completed
    @completed = true
  end

  def completed?
    @completed
  end

  def deleted?
    @deleted
  end

  def modified?  # Object in memory is "dirty" and
    @modified    # needs to be saved?
  end

end

