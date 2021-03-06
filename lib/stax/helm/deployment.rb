## tasks to work on deployments
module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def helm_deployments
          jsonpath = '{.items[*].metadata.name}'
          %x[kubectl get deployments -o=jsonpath='#{jsonpath}' -l #{helm_selector}].split
        end

        ## prompt user with a list of deployments to choose
        def helm_ask_deployments(msg)
          deployments = helm_deployments
          if deployments.count > 1
            puts deployments.each_with_index.map { |d, i| "#{i}: #{d}" }
            resp = ask(msg, default: 'all')
            if resp != 'all'
              indices = resp.split.map(&:to_i)
              deployments = Array(deployments.slice(*indices))
            end
          end
          deployments
        end
      end

      desc 'deployments', 'list deployments'
      def deployments
        kubectl_run(:get, :deployments, '-l', helm_selector)
      end

      desc 'restart', 'restart deployments'
      def restart
        helm_ask_deployments('choose deployments').each do |deployment|
          kubectl_run(:rollout, :restart, :deployment, deployment)
        end
      end

      desc 'scale', 'show/set scale for deployments'
      method_option :replicas, aliases: '-r', type: :numeric, default: nil, desc: 'replicas'
      def scale
        if options[:replicas]
          deployments = helm_ask_deployments('choose deployments').join(' ')
          kubectl_run(:scale, :deployment, deployments, '--replicas', options[:replicas])
        else
          debug("Deployment replicas for #{helm_release_name}")
          deployments = kubectl_json(:get, :deployments, '-l', helm_selector)
          print_table deployments['items'].map { |i|
            [ i['metadata']['name'], i['status']['replicas'] || 0 ]
          }
        end
      end

    end
  end
end
