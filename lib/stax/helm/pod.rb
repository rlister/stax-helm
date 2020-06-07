## tasks to work on pods
module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def helm_pods
          jsonpath = '{.items[*].metadata.name}'
          %x[kubectl get pods -o=jsonpath='#{jsonpath}' #{selector('app.kubernetes.io/instance': helm_release_name)}].split
        end

        def helm_ask_pod(msg)
          pods = helm_pods
          index = 0
          if pods.count > 1
            puts pods.each_with_index.map { |p, i| "#{i}: #{p}" }
            index = ask(msg, default: index)
          end
          pods[index.to_i]
        end
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

      desc 'logs [OPTIONS]', 'run kubectl logs with same options'
      def logs(*args)
        args = [ '--all-containers', '--prefix', '--follow' ] if args.empty? # helpful default args
        kubectl_run(:logs, selector('app.kubernetes.io/instance': helm_release_name), *args)
      end

      desc 'exec [CMD]', 'exec command in a web pod'
      def exec(cmd = 'sh')
        pod = helm_ask_pod('choose a pod')
        kubectl_run(:exec, '-it', pod, '--', cmd)
      end

    end
  end
end
