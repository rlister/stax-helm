## tasks to get cronjob details
module Stax
  module Helm
    class Cmd < Base

      desc 'cronjobs', 'list cronjobs'
      def cronjobs
        kubectl_run(:get, :cronjobs, '-l', helm_selector)
      end

    end
  end
end
