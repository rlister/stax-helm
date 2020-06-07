## tasks to get ingress details
module Stax
  module Helm
    class Cmd < Base

      desc 'ingresses', 'list ingresses'
      def ingresses
        kubectl_run(:get, :ingresses, selector('app.kubernetes.io/instance': helm_release_name))
      end

      desc 'dns', 'list external-dns hostnames'
      def dns
        jsonpath = '{.items[].metadata.annotations.external-dns\.alpha\.kubernetes\.io/hostname}' + "\n"
        kubectl_run(:get, :ingresses, "-o=jsonpath='#{jsonpath}'", selector('app.kubernetes.io/instance': helm_release_name))
      end

    end
  end
end
