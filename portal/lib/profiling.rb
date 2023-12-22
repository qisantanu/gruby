require 'benchmark'

def profile_memory
  memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i
  yield
  memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

  used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
  message = "Memory usage: #{used_memory} MB"
  puts message
  Rails.logger.info message
end

def profile_time
  time_elapsed = Benchmark.realtime do
    yield
  end
  message = "Time taken: #{time_elapsed.round(2)} seconds"
  puts message
  Rails.logger.info message
end

def profile_gc
  GC.start
  before = GC.stat(:total_freed_objects)
  yield
  GC.start
  after = GC.stat(:total_freed_objects)
  message = "Objects Freed: #{after - before}"
  puts message
  Rails.logger.info message
end

def profile
  profile_memory do 
    profile_time do 
      profile_gc do
        yield
      end
    end 
  end 
end