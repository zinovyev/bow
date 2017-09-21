# frozen_string_literal: true

module Bow
  module Memorable
    def task_history
      @task_history ||= History.load
    end

    def update_history(step = {})
      task_history.add(name, step) unless step.empty?
    end

    def flush_history
      task_history.flush
    end

    def apply!
      update_history(applied: Time.now.to_i)
    end

    def applied?
      task_hist = task_history.get(name)
      return false if !task_hist || task_hist.empty?
      !!task_hist.last['applied']
    end
  end
end
