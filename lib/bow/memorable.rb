# frozen_string_literal: true

module Bow
  module Memorable
    def task_history
      @task_history ||= Locker.load
    end

    # def update_history(step = {})
      # task_history.add(name, step) unless step.empty?
    # end

    def flush_history
      task_history.flush
    end

    def apply
      task_history.apply(name)
    end

    def applied?
      task_history.applied?(name)
    end

    def revert(task)
      task_history.revert(name)
    end

    def reverted?
      task_history.reverted?(name)
    end

    def reset(task)
      task_history.reset(task)
    end
  end
end
