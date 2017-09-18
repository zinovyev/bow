require 'rake'
require 'bow'
require 'pry'

module Bow
  class Rake; end
end

module Rake
  module DSL

    # Extend next rake task.
    #
    # Example:
    #   set run: :once, enabled: true, revert: :world_down
    #   task world: [:build] do
    #     # ... build world
    #   end
    #
    #   task :world_down do
    #     # ... destroy world
    #   end
    def ext(*extensions) # :doc:
      Rake.application.last_extensions = extensions
    end
  end

  module TaskManager
    attr_accessor :last_extensions

    # Lookup a task.  Return an existing task if found, otherwise
    # create a task of the current type.
    def intern(task_class, task_name)
      @tasks[task_name.to_s] ||= task_class.new(task_name, self)
      task = @tasks[task_name.to_s]
      task.unpack_extensions(get_extensions(task))
      task
    end

    # Return current extensions, clearing it in the process.
    def get_extensions(_task)
      @last_extensions ||= nil
      ext = @last_extensions&.first
      @last_extensions = nil
      ext
    end
  end

  class Task
    include ::Bow::Memorable
    ALLOWED_EXTENSIONS = %i[run enabled revert].freeze

    alias orig__clear clear
    alias orig__invoke_with_call_chain invoke_with_call_chain

    # rubocop:disable Lint/RescueException
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def invoke_with_call_chain(task_args, invocation_chain) # :nodoc:
      load_history
      if disabled?
        return unless active?
        if revert_task = find_revert_task
          result = revert_task.execute unless revert_task.applied?
        end
        active = false
        update_history
        return result
      end
      return if run_once? && applied?
      result = orig__invoke_with_call_chain(task_args, invocation_chain)
      active = false if run_once?
      update_history
      result
    # rescue Exception => ex
      # add_chain_to(ex, new_chain)
      # raise ex
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Lint/RescueException

    def clear
      clear_extensions
      orig__clear
    end

    def clear_extensions
      @extensions = {}
      self
    end

    def run_once?
      @extensions ||= {}
      @extensions[:run] == :once
    end

    def disabled?
      !enabled?
    end

    def enabled?
      @extensions ||= {}
      !!@extensions[:enabled]
    end

    def find_revert_task
      task_name = @extensions[:revert] if @extensions[:revert]
      application.lookup(task_name)
    end

    def add_extension(ext, val)
      return unless ALLOWED_EXTENSIONS.include? ext
      @extensions ||= {}
      @extensions[ext.to_sym] = val
    end

    # Add extensions set to the task.
    def unpack_extensions(extensions)
      # binding.pry
      return unless extensions
      extensions.each { |ext, val| add_extension(ext, val) }
    end
  end
end
