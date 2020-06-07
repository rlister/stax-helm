## tasks to work on deployments
module Stax
  module Helm
    class Cmd < Base

      desc 'deployments', 'list deployments'
      def deployments
        kubectl_run(:get, :deployments, selector('app.kubernetes.io/instance': helm_release_name))
      end

    end
  end
end
