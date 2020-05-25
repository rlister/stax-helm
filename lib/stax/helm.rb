require 'stax/helm/cmd'
require 'stax/helm/kubectl'
require 'stax/helm/stern'
Stax.add_command(:helm, Stax::Helm::Cmd)
