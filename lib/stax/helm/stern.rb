module Stax
  module Helm
    class Cmd < Base

      no_commands do
        def stern_bin
          'stern'
        end

        def stern_run(*args)
          cmd = [stern_bin, *args].join(' ')
          options[:dry_run] ? puts(cmd) : system(cmd)
        end
      end

      ## pass through args to stern
      desc 'stern [STERN_ARGS]', 'use stern to show logs'
      def stern(*args)
        trap('SIGINT', 'EXIT')    # clean exit with ctrl-c
        stern_run('-l', helm_selector, *args)
      end

    end
  end
end
