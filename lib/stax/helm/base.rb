puts 'loading'
module Stax
  class Base < Thor

    no_commands do
      def helm_release_name
        @_helm_release_name ||= helm_safe("#{app_name}-#{branch_name}")
      end

      ## make string safe to use in naming helm stuff
      def helm_safe(string)
        string.slice(0, 53).gsub(/[\W_]/, '-').downcase
      end
    end

  end
end
