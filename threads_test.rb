require 'bow'

def run
  t = Bow::ThreadPool.new
  t.add { sleep 1; p 'foo1' }
  t.add { sleep 1; p 'foo2' }
  t.add { sleep 1; p 'foo3' }
  t.add { sleep 1; p 'foo4' }
  t.add { sleep 1; p 'foo5' }
  t.add { sleep 1; p 'foo6' }
  t.run
  # Bow::ThreadPool.new do |t|
    # t.collection = [1, 2, 3, 4]
    # t.handler = proc { |c| p "SAY: #{c}" }
  # end.join
end

run
