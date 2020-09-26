module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def kubectl_bin
          'kubectl'
        end

        def kubectl_run(*args)
          cmd = [kubectl_bin, *args].join(' ')
          options[:recon] ? puts(cmd) : system(cmd)
        end

        def kubectl_json(*args)
          args.push('-o=json')
          cmd = [kubectl_bin, *args].join(' ')
          options[:recon] ? puts(cmd) : JSON.parse(%x(#{cmd}))
        end

        ## override this to match all objects in your helm release
        def helm_selector
          "app.kubernetes.io/instance=#{helm_release_name}"
        end
      end

      desc 'services', 'list services'
      def services
        kubectl_run(:get, :services, '-l', helm_selector)
      end

    end
  end
end
