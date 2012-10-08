require "queue_classic"

class GistedWorker < QC::Worker

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  add_transaction_tracer :call, :category => :task, :params => '{ :job => args[0][:method], :args => args[0][:args] }'

  FQ = QC::Queue.new 'failed'


  # Hate wholesale-overriding like this, but there weren't any better hooks to access to
  # modify logging (wanted info log statement on delete_job)
  def work
    if job = lock_job
      QC.log_yield(:action => "work_job", :job => job[:id]) do
        begin
          call(job)
          log(:action => "finished_work", :job => job[:id])
        rescue Object => e
          log(:action => "failed_work", :job => job[:id], :error => e.inspect)
          handle_failure(job, e)
        ensure
          @queue.delete(job[:id])
          log(:action => "delete_job", :job => job[:id])
        end
      end
    end
  end

  def handle_failure(job, exception)

    # From QC::Worker
    klass = eval(job[:method].split(".").first)
    message = job[:method].split(".").last

    # Log exception & store failed job
    FQ.enqueue(job[:method], *job[:args])
    log_exception({ns: klass, fn: message, job_args: job[:args]}, exception)
    Airbrake.notify(exception, parameters: job)

    # # Retry
    # log(ns: self, fn: __method__, at: 'retry-job', job: job[:method], job_args: job[:args])
    # @queue.enqueue(job[:method], *job[:args])
  end

  # # the forked proc needs a new db connection
  # def setup_child
  #   ActiveRecord::Base.establish_connection
  # end

end