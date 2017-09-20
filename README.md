# bow

  Automate your infrastructure provisioning and configuration with Rake.

[![Build Status](https://travis-ci.org/zinovyev/bow.svg?branch=master)](https://travis-ci.org/zinovyev/bow)

## About

Bow is a system that allows you to write Rake tasks and execute them remotely
to provision and configure you servers.

## Why?

Well...

I do know about dozens of [configuration management](https://en.wikipedia.org/wiki/ Comparison_of_open-source_configuration_management_software) software. And I've also used to use some of them.
And I really like a couple of them too.

But when it comes to a simple goal like configuring 2 or 3 VPS nodes I don't
really want to create a complex infrastructure (any infrastructure to be honest)
for it and I like to do it in Ruby (well, maybe in Bash and Ruby).

And I like a great tool called Rake as you do it too =))

Bow is simple, agentless and it doesn't bring it's own DSL to life, cause it
uses Rake instead.

## Usage

1. If you're not familiar with Rake [Rake docs](https://ruby.github.io/rake/) and [Rake home](https://github.com/ruby/rake) can be a good place to start from;

2. Install the `bow` gem with:

```bash

gem install bow

``` 

3. Create an empty folder and init a basic structure there:

```bash

mkdir ~/bow-test

cd ~/bow-test

bow init

```

4. The command `bow init` called above created a bare structure wich consits
of a `Rakefile` and a list of targets (managed servers) in `targets.json` file.

The example targets file contains 4 IPs combined in two managed groups:

```json

{
  "example_group1": [
    "192.168.50.27",
    "192.168.50.37"
  ],
  "example_group2": [
    "192.168.50.47",
    "192.168.50.57"
  ]
}

```

A `Rakefile` contains two tasks for provisioning packed in namespaces wich are
called by the name of the server groups from the `targets.json` file. The main
task of the group MUST always be called **provision** and can be bound to any
number of additional tasks. Sometimes (always) it is convinient to put
additional tasks them to separate files into the [rakelib](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Multiple+Rake+Files) folder.


```ruby

require 'bow/rake'

Rake.application.options.trace_rules = true

PROVISION_DIR = '/tmp/rake_provision'.freeze

flow run: :once, enabled: true, revert: :good_night_world
task :hello_world do
  p 'Hello world!'
end

task :good_night_world do
  p 'Good night world!'
end

namespace :example_group1 do
  task provision: [:print_hello] do
    sh 'echo "Hello from example group #1 server!"'
  end
end

namespace :example_group2 do
  task :provision do
    sh 'echo "Hello from example group #2 server!"'
  end
end

task :print_hello do
  sh 'echo "Hello World"'
end

task :print_date do
  puts `date`
end

```

5. Now run `bow apply` and your provisioning tasks will be executed on servers;

6. To find more commands (`ping`, `exec` etc.) type `bow -h`;

## Task flow

While that is not necessary, it can be convinient to install a `bow` gem on the
client server too. So you will be able to use a little Rake DSL enhancement
wich bring a better controll of the flow of your tasks.

The only thing you will be needed to do afterwards to enable the feature is to
require it by putting `require bow/rake` to the top of your `Rakefile`.

Now you'll be able to put this `flow` line before the task definition:

```ruby

flow run: :once, enabled: :true, revert: :revert_simple_task
task :simple_task do
  # some code here ...
end

task :revert_simple_task do
  # remove evertything that simple task have done >/ 
end

```

The 3 options are:

* `run` wich can be either `:once` or `:always`. If set to `once` the task will
be run only once on remote server;

* `enabled` wich takes a boolean value. If set to false, the task will be
disabled and won't run at all;

* `revert` wich defines a task that can revert changes done by the original
task when the original task is disabled (by `enabled: false` option). Actually
it's something similar to the down migration when dealing with databases;


