module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def kubectl_bin
          'kubectl'
        end

        def kubectl_run(*args)
          cmd = [kubectl_bin, *args].join(' ')
          options[:dry_run] ? puts(cmd) : system(cmd)
        end

        ## build a selector argument from a hash of label and value pairs
        def selector(hash)
          '-l ' + hash.compact.map { |k,v| "#{k}=#{v}" }.join(',')
        end
      end

      desc 'services', 'list services'
      def services
        kubectl_run(:get, :services, selector('app.kubernetes.io/instance': helm_release_name))
      end

      desc 'ingresses', 'list ingresses'
      def ingresses
        kubectl_run(:get, :ingresses, selector('app.kubernetes.io/instance': helm_release_name))
      end

      desc 'deployments', 'list deployments'
      def deployments
        kubectl_run(:get, :deployments, selector('app.kubernetes.io/instance': helm_release_name))
      end

      desc 'pods', 'list pods'
      def pods
        kubectl_run(:get, :pods, selector('app.kubernetes.io/instance': helm_release_name))
      end

      desc 'containers', 'list containers'
      def containers
        columns = 'NAME:.metadata.name,CONTAINERS:.spec.containers[*].name'
        kubectl_run(:get, :pods, '-o', "custom-columns=#{columns}", selector('app.kubernetes.io/instance': helm_release_name))
      end

      ## FIXME this is terrible, will be replaced with something better later
      desc 'logs COMPONENT [CONTAINER]', 'show container logs'
      method_option :container, aliases: '-c', type: :string, default: nil, desc: 'container from pod'
      def logs(component)
        container = options[:container] ? "-c #{options[:container]}" : ''
        kubectl_run(
          :logs,
          container,
          selector(
            'app.kubernetes.io/instance': helm_release_name,
            'app.kubernetes.io/component': component,
          )
        )
      end

    end
  end
end
