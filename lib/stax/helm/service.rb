## tasks to work on services
module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def helm_services
          jsonpath = '{.items[*].metadata.name}'
          %x[kubectl get services -o=jsonpath='#{jsonpath}' -l #{helm_selector}].split
        end
      end

      desc 'services', 'list services'
      def services
        kubectl_run(:get, :services, '-l', helm_selector)
      end

      map :svc => :services

      desc 'port-forward', 'port forward a service'
      method_option :component, aliases: '-c', type: :string, default: 'web', desc: 'component to forward'
      method_option :ports,     aliases: '-p', type: :array,  default: nil,   desc: 'local:remote ports'
      def port_forward
        svc = kubectl_json(:get, :svc, '-l', helm_component_selector(options[:component]))['items'].first
        name = svc.dig('metadata', 'name')
        ports = options.fetch(:ports, svc.dig('spec', 'ports').map { |p| p['port'] })
        kubectl_run('port-forward', "service/#{name}", ports.join(' '))
      end

    end
  end
end
