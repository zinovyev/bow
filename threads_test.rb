require 'bow'

def run
  enum = (1..100)
  Bow::ThreadPool.new do |t|
    t.from_enumerable(enum) do |e|
      v = rand(1..5)
      sleep v
      puts "s: #{v}; e: #{e}"
    end
  end
  # t = Bow::ThreadPool.new
  # t.add { v = rand(1..10); sleep v; p "foo1: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo2: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo3: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo4: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo5: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo6: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo7: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo8: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo9: #{v}" }
  # t.add { v = rand(1..10); sleep v; p "foo10: #{v}" }
  # t.run
end

run
