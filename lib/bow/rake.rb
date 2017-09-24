# frozen_string_literal: true

require 'rake'
require 'bow'

module Bow
  class Rake; end
end

module Rake
  module DSL
    # Describe the flow of the next rake task.
    #
    # Example:
    #   flow run: :once, enabled: true, revert: :world_down
    #   task world: [:build] do
    #     # ... build world
    #   end
    #
    #   task :world_down do
    #     # ... destroy world
    #   end
    def flow(*flow) # :doc:
      Rake.application.last_flow = flow
    end
  end

  module TaskManager
    attr_accessor :last_flow

    # Lookup a task.  Return an existing task if found, otherwise
    # create a task of the current type.
    def intern(task_class, task_name)
      @tasks[task_name.to_s] ||= task_class.new(task_name, self)
      task = @tasks[task_name.to_s]
      task.unpack_flow(get_flow(task))
      task
    end

    # Return current flow, clearing it in the process.
    def get_flow(_task)
      @last_flow ||= nil
      flow = @last_flow&.first
      @last_flow = nil
      flow
    end
  end

  class Task
    include ::Bow::Memorable

    ALLOWED_FLOW_RULES = %i[run enabled revert].freeze

    alias orig__clear clear
    alias orig__invoke_with_call_chain invoke_with_call_chain

    def invoke_with_call_chain(task_args, invocation_chain) # :nodoc:
      return apply_revert_task if disabled?
      return if run_once? && applied?
      result = orig__invoke_with_call_chain(task_args, invocation_chain)
      apply if run_once?
      flush_history
      result
    end

    def apply_revert_task
      revert_task = find_revert_task
      return if reverted? || !revert_task || revert_task.applied?
      result = revert_task.execute
      revert_task.apply if revert_task.run_once?
      revert
      flush_history
      result
    end

    def clear
      clear_flow
      orig__clear
    end

    def clear_flow
      @flow = {}
      self
    end

    def disabled?
      !enabled?
    end

    def run_once?
      flow[:run] == :once
    end

    def enabled?
      !!flow[:enabled]
    end

    def flow
      @flow ||= { enabled: true, run: :always, revert: nil }
    end

    def find_revert_task
      binding.pry
      task_name = flow[:revert] if flow[:revert]
      application.lookup(task_name)
    end

    # Add flow to the task.
    def unpack_flow(init_flow)
      return unless init_flow
      init_flow.each { |rule, val| add_flow_rule(rule, val) }
    end

    def add_flow_rule(rule, val)
      return unless ALLOWED_FLOW_RULES.include? rule
      flow[rule.to_sym] = val
    end
  end
end
