module CP_Profiler
  @@stacks = {}
  @@maps = {}
  @@frames_passed = 0
  def self.begin
    @@frames_passed = Graphics.frame_count
    @@stacks = {}
    @@maps = {}
    set_trace_func proc { |event, file, line, id, binding, klass|
    case event
      when "call"
        now = Process.times[0]
        stack = (@@stacks[Thread.current] ||= [])
        stack.push [now, 0.0]
      when "return"
        now = Process.times[0]
        key = "#{klass}##{id}##{line}##{event}##{file}"
        stack = (@@stacks[Thread.current] ||= [])
        if tick = stack.pop
          threadmap = (@@maps[Thread.current] ||= {})
          data = (threadmap[key] ||= [0.0, 0, key])
          data[0] += now - tick[0] - tick[1]
          data[1] +=1
          stack[-1][1] += now - tick[0] if stack[-1]
        end
        
    end
    }
  end
  def self.print
    @@frames_passed = Graphics.frame_count - @@frames_passed
    set_trace_func nil
    total = Process.times[0]
    total = 0.01 if total == 0
    totals = {}
    @@maps.values.each do |threadmap|
      threadmap.each do |key,data|
        total_data = (totals[key] ||= [0.0, 0 , key])
        total_data[0] += data[0]
        total_data[1] += data[1]
      end
    end
    data = totals.values
    data = data.sort_by{ |x| -x[0] }
    sum = 0
    File.open('Data/Profiler.txt', 'w') do |file|
      file.print("Amount of frames that passed: #{@@frames_passed}\n")
      text = sprintf  "call time  cumulative   self        calls\n"
      file.print(text)
      text = sprintf  "     ms   seconds   seconds           name\n"
      file.print(text)
      for d in data
        next if d[0] <= 0.0
        sum += d[0]
        text = sprintf "%8.3f %8.2f  %8.2f %10i %s\n",
        d[0]/d[1]*1000, sum, d[0], d[1], d[2]
        file.print(text)
      end
      Kernel.pbMessage("Results printed to profiler.txt.")
    end
  end
end