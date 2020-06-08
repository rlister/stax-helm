## tasks to work on deployments
module Stax
  module Helm
    class Cmd < Base

      desc 'deployments', 'list deployments'
      def deployments
        kubectl_run(:get, :deployments, '-l', helm_selector)
      end

    end
  end
end
