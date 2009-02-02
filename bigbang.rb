require 'timecop'

TimeCop.kill_store("data",true)
TimeCop.open_store

# Extra indentation for easy commenting...

  Task.create_task("aa create_task: Unique, no date, no time")
  Task.create_appt("ab create_appt: Unique, no date, no time")
  Task.create_todo("ac create_todo: Unique, no date, no time")
  
  Task.create_task("ba create_task: Unique, with date, no time","2009/02/12")
  Task.create_appt("bb create_appt: Unique, with date, no time","2009/02/14")
# Task.create_todo("bc create_todo: Unique, with date, no time","2009/02/16")   # error

  Task.create_task("ca create_task: Unique, date, time","2009/02/18",Time.now)
  Task.create_appt("cb create_appt: Unique, date, time","2009/02/20",Time.now)
# Task.create_todo("cc create_todo: Unique, date, time","2009/02/22",Time.now)  # error
  
  Task.create_daily_task("da create_daily_task: Daily, no time")
  Task.create_daily_appt("db create_daily_appt: Daily, no time")
  Task.create_daily_todo("dc create_daily_todo: Daily, no time")
  
  Task.create_daily_task("ea create_daily_task: Daily, with time", Time.now)
  Task.create_daily_appt("eb create_daily_appt: Daily, with time", Time.now)
# Task.create_daily_todo("ec create_daily_todo: Daily, with time", Time.now)    # error
  
  Task.create_weekly_task("fa create_weekly_task: Weekly, no date, no time")
  Task.create_weekly_appt("fb create_weekly_appt: Weekly, no date, no time")
# Task.create_weekly_todo("fc create_weekly_todo: Weekly, no date, no time")    # error
  
  Task.create_weekly_task("ga create_weekly_task: Weekly, Sunday-string, no time","Sunday")
  Task.create_weekly_task("gb create_weekly_appt: Weekly, Monday-symbol, no time",:monday)
  Task.create_weekly_appt("gc create_weekly_task: Weekly, Tueday-string, no time","tuesday")
  Task.create_weekly_appt("gd create_weekly_appt: Weekly, Wednesday-symbol, no time",:Wednesday)
  Task.create_weekly_todo("ge create_weekly_todo: Weekly, Thursday-string, no time","thu")    
  Task.create_weekly_todo("gf create_weekly_todo: Weekly, Friday-symbol, no time",:fri)     
  
  Task.create_weekly_task("gg create_weekly_task: Weekly, Sunday, time", "Sunday", "12:34")
  Task.create_weekly_appt("gg create_weekly_task: Weekly, Monday, time", "Monday", "12:34")
# Task.create_weekly_todo("gg create_weekly_task: Weekly, Monday, time", "Monday", "12:34")  # error

  Task.create_monthly_date_task("ha create_monthly_date_task: Monthly/date, 15th, no time",Date.new(2009,2,15))
  Task.create_monthly_date_task("hb create_monthly_date_task: Monthly/date, 17th, no time",Date.new(2009,2,17))
  Task.create_monthly_date_appt("hc create_monthly_date_task: Monthly/date, 18th, no time",Date.new(2009,2,18))
  Task.create_monthly_date_appt("hd create_monthly_date_task: Monthly/date, 20th, no time",Date.new(2009,2,20))
  Task.create_monthly_date_todo("he create_monthly_date_task: Monthly/date, 22th, no time",Date.new(2009,2,22))
  Task.create_monthly_date_todo("hf create_monthly_date_task: Monthly/date, 24th, no time",Date.new(2009,2,24))
