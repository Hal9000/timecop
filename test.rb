require 'timecop'

TimeCop.open_store

Task.create_task("this is a task with a very long text field indeed")

t = Task.create_monthly_weekday_task("Let's try this now",:monday,1,3)
# t.save

t2 = Task.create_task("I'll be deleted")
t3 = Task.create_task("I'll stick around")

t2.delete

list = TimeCop.load_store
list2 = list.compact
list2.each {|x| p x}

# Some more things to test:
#   1. text is never optional
#   2. create_task works with/without date/time
#   3. create_appt defaults to today
#   4. create_appt works with/without an explicit time
#   5. A Date object or a Time object can be passed in for a date
#   6. Any time passed in overrides any time supplied as part of the date
#   7. :today, :yesterday, and :tomorrow are recognized, both as symbols
#      and as strings
#   8. Any object with a to_str can be used as text
#   9. Every create_* method can take a block
#  10. Store: nextid starts at 0
