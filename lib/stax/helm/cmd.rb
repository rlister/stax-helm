module Stax
  module Helm
    class Cmd < Base
      class_option :dry_run, type: :boolean, default: false, desc: 'print command that would be run'

      no_commands do
        def helm_release_name
          @_helm_release_name ||= "#{app_name}-#{branch_name}"
        end

        ## location of helm chart
        def helm_dir
          File.join(Stax.root_path, 'helm')
        end

        ## location of helm binary
        def helm_bin
          'helm'
        end

        ## run helm with args
        def helm_run(*args)
          cmd = [helm_bin, *args].join(' ')
          options[:dry_run] ? puts(cmd) : system(cmd)

        ## description added to release
        def helm_description
          Git.sha
        end

        ## override with full path to a values.yaml file
        def helm_values_file
          nil
        end

        ## override with hash of extra values to set
        def helm_values
          {}
        end

        ## construct args for install and upgrade commands
        def helm_update_args
          [].tap do |args|
            args.push("--description #{helm_description}") if helm_description
            args.push("-f #{helm_values_file}") if helm_values_file
            args.push(helm_values&.map { |k,v| "--set #{k}=#{v}" })
          end.flatten
        end
      end

      desc 'create', 'create helm release'
      def create
        debug("Creating helm release #{helm_release_name}")
        helm_run(:install, helm_release_name, helm_dir, helm_update_args)
      end

      desc 'update', 'update helm release'
      def update
        debug("Updating helm release #{helm_release_name}")
        helm_run(:upgrade, '-i', helm_release_name, helm_dir, helm_update_args)
      end

      desc 'delete', 'delete helm release'
      def delete
        debug("Deleting helm release #{helm_release_name}")
        helm_run(:delete, helm_release_name)
      end

      desc 'status', 'get helm status'
      def status
        helm_run(:status, helm_release_name)
      end

      desc 'template', 'get helm chart'
      def template
        helm_run(:get, :all, helm_release_name)
      end

      desc 'values', 'get helm values'
      def values
        helm_run(:get, :values, helm_release_name)
      end

      desc 'history', 'get helm history'
      def history
        helm_run(:history, helm_release_name)
      end

      desc 'rollback [REVISION]', 'rollback helm release'
      def rollback(revision = nil)
        helm_run(:rollback, helm_release_name, revision)
      end

      desc 'ls', 'list helm release'
      def ls
        helm_run(:ls, "--filter '^#{helm_release_name}$'")
      end

    end
  end
end
