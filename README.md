# Pier

Pier is an alternative Docker client, which uses the Ruby [docker-api](https://github.com/swipely/docker-api) gem to access the Docker Remote API. Pier is focused on the use-case of managing one or more clusters of machines which are entirely dedicated to running a Docker swarm.

Pier uses [fog](http://fog.io/) for its instance management. For now, only the [fog-libvirt](https://github.com/fog/fog-libvirt) backend is supported.

Pier assumes that each cluster has a cluster-manager endpoint, called a "pier." The pier is a running instance that must:

* be accessible via SSH;
* be a manager in your Docker swarm; and
* have `easy-rsa` installed and set up to generate both server and client certificates.

A pier need not be a member of the cluster itself. Pier does not manage the pier, only the cluster visible through the pier.

By default, Pier also assumes that each pier is the _libvirt hypervisor_ for its cluster—i.e. that libvirt's endpoint is accessible as `qemu+ssh://[your-pier-endpoint]/system`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'docker-pier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docker-pier

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tsutsu/docker-pier.

