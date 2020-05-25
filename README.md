# Stax::Helm

[Stax](https://github.com/rlister/stax) is a highly-opionated framework for managing Cloudformation stacks.

Stax::Helm is highly-opionated framework for managing helm releases alongside their supporting Cloudformation stacks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stax-helm
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stax-helm

## Opinions

- you have one chart per application repo
- chart lives in `helm` dir alongside your `Staxfile`
- objects are labeled per the suggestions in
  https://helm.sh/docs/chart_best_practices/labels/ and
  https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/

## Usage

In your `Staxfile` add:

```ruby
require 'stax/helm'
```

and use commands like:

```
stax helm create
stax helm update
stax helm delete
```

See inline help for other tasks.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
