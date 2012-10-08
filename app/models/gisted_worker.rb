require "queue_classic"

class GistedWorker < QC::Worker

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  add_transaction_tracer :call, :category => :task, :params => '{ :job => args[0][:method], :args => args[0][:args] }'

  # # retry the job
  # def handle_failure(job, exception)
  #   @queue.enqueue(job[:method], *job[:args])
  # end

  # # the forked proc needs a new db connection
  # def setup_child
  #   ActiveRecord::Base.establish_connection
  # end

end