## tasks to get job details
module Stax
  module Helm
    class Cmd < Base

      desc 'jobs', 'list jobs'
      def jobs
        kubectl_run(:get, :jobs, '-l', helm_selector)
      end

    end
  end
end
