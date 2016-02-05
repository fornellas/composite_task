# Simple implementation of GoF Composite pattern.
class CompositeTask

  # Task name (can be nil for top level task).
  attr_reader :name

  # Array of all CompositeTask instances that compose this Task
  attr_reader :sub_tasks

  # Task action (ie: given block). Can be nil for grouping only tasks.
  attr_reader :action

  # IO like object where to write progress to.
  attr_reader :io

  # Creates a new CompositeTask, and can be used in several fashions.
  #
  # For an ananymous top level class:
  #   task = CompositeTask.new()
  # For a named task:
  #   task = CompositeTask.new("Task witohut action")
  # For a named task, with an action block:
  #   task = CompositeTask.new("Task with action") do |task|
  #     puts "Executing action for #{task.name}"
  #   end
  # Once created, you can compose your task with #add_sub_task and then #execute it.
  #
  # Progress reporting is done to given io. can be set to nil to disable reporting.
  # :call-seq:
  # initialize()
  # initialize(nil, io=STDOUT)
  # initialize(name, io=STDOUT)
  # initialize(name, io=STDOUT) {|task| ... }
  def initialize(name=nil, io=STDOUT, &action)
    @name = name
    @io = io
    @action = action
    if action && !name
      raise ArgumentError.new('Anonymous tasks are only allowed without a block.')
    end
    @sub_tasks = []
  end

  # Adds a new sub task directly, or by passing its arguments (same as \#initialize).
  # :call-seq:
  # add_sub_task(task)
  # add_sub_task(name) {|task| ... }
  def add_sub_task(task_or_name, &action)
    if task_or_name.kind_of?(self.class)
      sub_tasks << task_or_name
    else
      sub_tasks << self.class.new(task_or_name, &action)
    end
  end

  # Adds a sub task without an action defined. Yields newly created task, so it can be used to compose the task:
  #   task.add_group("Group of tasks") do |g|
  #      g.add_task('task1') { puts 'from task1 inside group' }
  #      g.add_task('task2') { puts 'from task2 inside group' }
  #   end
  def add_group name # :yields: sub_task
    sub_tasks << ( sub_task = self.class.new(name) )
    yield sub_task
    self
  end

  # Execute all added sub tasks (#sub_tasks) in order, then execute itself (#call_action).
  # :call-seq:
  # execute()
  def execute(indent = 0)
    if leaf?
      call_action(indent)
    else
      write_bright("#{'  ' * indent}#{name}\n") if name
      increment = name ? 1 : 0
      sub_tasks.each do |task|
        task.execute(indent + increment)
      end
      call_action(indent + increment)
    end
  end

  # Whether it has sub tasks.
  def leaf?
    sub_tasks.empty?
  end

  # Total number tasks with action that compose this task (exclude "grouping only" tasks).
  def length
    sub_tasks.reduce(action ? 1 : 0) {|acc, sub_task| acc + sub_task.length}
  end
  alias_method :size, :length

  # All tasks that self is composed (including self).
  # :call-seq:
  # tasks -> Enumerator
  # tasks {|task| ... }
  def tasks &block
    return to_enum(__method__) unless block_given?
    yield self
    sub_tasks.each do |sub_task|
      sub_task.tasks(&block)
    end
  end

  # Whether self has an action.
  def has_action?
    !!action
  end

  # All tasks that self is composed (including self), only includen the ones where #has_action? is true.
  # :call-seq:
  # tasks -> Enumerator
  # tasks {|task| ... }
  def tasks_with_action
    return to_enum(__method__) unless block_given?
    tasks.each do |task|
      yield task if task.has_action?
    end
  end

  # Returns the first task with action with given name.
  def [] name
    tasks_with_action.select{|s| s.name == name}.first
  end

  # Execute self action only, without executing any of its sub tasks.
  # :call-seq: call_action
  def call_action indent = 0
    if action
      write_bright "#{'  ' * indent}#{name}... "
      begin
        @action.call(self)
      rescue
        write_red "[FAIL]\n"
        raise $!
      else
        write_green "[OK]\n"
      end
    else
      if leaf?
        raise RuntimeError.new("Leaf #{name ? "\"#{name}\" " : nil}with undefined action is not allowed.")
      end
    end
  end

  private

  ANSI_RESET       = "\e[0m"
  ANSI_ATTR_BRIGHT = "\e[1m"
  ANSI_FG_GREEN    = "\e[32m"
  ANSI_FG_RED      = "\e[31m"

  def colorize attribute, message
    if io.tty?
      io.write "#{ANSI_RESET}#{Object.const_get("#{self.class}::ANSI_#{attribute.to_s.upcase}")}#{message}#{ANSI_RESET}"
    else
      io.write message
    end
  end

  def write_bright message
    colorize(:attr_bright, message)
  end

  def write_green message
    colorize(:fg_green, message)
  end

  def write_red message
    colorize(:fg_red, message)
  end

end
