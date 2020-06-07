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

    end
  end
end
