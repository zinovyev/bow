module Bow
  module Memorable
    def initialize(task, _inventory = nil)
      @task = task
      @task_history = TaskHistory.load
    end

    def load_history

    end

    def update_history

    end

    def parse_hist; end

    def active?
      true
    end

    def applied?
      false
    end
  end
end
