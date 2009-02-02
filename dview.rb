require 'timecop'

TimeCop.open_store
list = TimeCop.load_store

target = Date.parse(ARGV.first)

list2 = list.select {|item| item.match?(target) }

list2.each {|x| p x}

