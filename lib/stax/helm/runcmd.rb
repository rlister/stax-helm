require 'open3'
require 'securerandom'

module Stax
  module Helm
    class Cmd

      no_commands do
        ## construct a Job template
        def helm_run_template(name)
          {
            apiVersion: 'batch/v1',
            kind: :Job,
            metadata: {
              name: name,
              labels: {
                'app.kubernetes.io/managed-by' => :stax
              }
            },
            spec: {
              template: {
                spec: {
                  restartPolicy: :Never
                }
              }
            }
          }
        end

        ## Deployment to clone for container
        def helm_run_deployment
          "#{helm_release_name}-web"
        end

        ## name of container to clone from Deployment
        def helm_run_container
          'web'
        end

        ## name for Job to create based on container
        def helm_run_job
          "#{helm_release_name}-run-#{SecureRandom.hex(4)}"
        end

        ## default command to run
        def helm_run_cmd
          'bash'
        end
      end

      ## task creates a dedicated unique kubernetes Job, with
      ## container spec based on the helm release deployment
      ## requested, then does an interactive exec to the pod and
      ## container created, and deletes the Job on exit
      desc 'runcmd [CMD]', 'run dedicated interactive container'
      method_option :sleep, type: :string,  default: '1h',  description: 'kill container after time'
      method_option :keep,  type: :boolean, default: false, description: 'do not delete job'
      method_option :ttl,   type: :numeric, default: 30,    description: 'secs to keep job after pod terminates'
      def runcmd(*cmd)
        ## use default if not set
        cmd = Array(helm_run_cmd) if cmd.empty?

        ## name of k8s Job to create, and basic template
        job = helm_run_job
        template = helm_run_template(job)

        ## get deployment and extract container spec
        deployment = kubectl_json(:get, :deployment, helm_run_deployment)
        spec = deployment.dig('spec', 'template', 'spec', 'containers').find do |c|
          c['name'] == helm_run_container
        end

        ## cleanup the container spec so we can use it in a Job
        spec.delete('livenessProbe')
        spec.delete('readinessProbe')
        spec.delete('startupProbe')
        spec.delete('volumeMounts')
        spec['name'] = 'run'
        spec['args'] = ['sleep', options[:sleep]]

        ## add container to Job template
        template[:spec][:template][:spec][:containers] = [ spec ]

        ## add ttl to Job so it will be cleaned up after Pod terminates
        template[:spec][:ttlSecondsAfterFinished] = options[:ttl]

        ## get service account and add to template
        service_account = deployment.dig('spec', 'template', 'spec', 'serviceAccountName')
        template[:spec][:template][:spec][:serviceAccountName] = service_account if service_account

        ## create new unique Job based on the container spec
        debug("Creating job #{job}")
        Open3.popen2('kubectl create -f -') { |stdin, stdout, _|
          stdin.print(template.to_json)
          stdin.close
          puts stdout.gets
        }

        ## get name of the Pod created by the Job
        pod = kubectl_json(:get, :pod, '-l', "job-name=#{job}")['items'].first['metadata']['name']

        ## exec into the pod and run interactive command
        debug("Connecting to pod #{pod}")
        kubectl_run(:wait, '--for=condition=Ready', '--timeout=5m', :pod, pod)
        kubectl_run(:exec, '-it', pod, '--', *cmd)
      rescue JSON::ParserError
        fail_task('cannot get kubernetes resource')
      ensure
        ## delete Job
        kubectl_run(:delete, :job, job) unless options[:keep]
      end
    end
  end
end
