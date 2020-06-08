## tasks to get ingress details
module Stax
  module Helm
    class Cmd < Base

      desc 'ingresses', 'list ingresses'
      def ingresses
        kubectl_run(:get, :ingresses, '-l', helm_selector)
      end

      desc 'dns', 'list external-dns hostnames'
      def dns
        jsonpath = '{.items[].metadata.annotations.external-dns\.alpha\.kubernetes\.io/hostname}' + "\n"
        kubectl_run(:get, :ingresses, "-o=jsonpath='#{jsonpath}'", '-l', helm_selector)
      end

    end
  end
end
