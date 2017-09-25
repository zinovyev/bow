# bow

  Automate your infrastructure provisioning and configuration with Rake.

[![Build Status](https://travis-ci.org/zinovyev/bow.svg?branch=master)](https://travis-ci.org/zinovyev/bow)
[![Gem Version](https://badge.fury.io/rb/bow.svg)](https://badge.fury.io/rb/bow)


## About

Bow doesn't bring its own DSL to live, rather it uses regular Rake tasks
instead.

It can be handy for you if:

 * you need to configure a pure system of 2-5 VPSs;

 * you don't want to build a complex infrastructure;

 * you are already familiar with Rake and don't want to to learn Python;


## Installation

Download and install bow with the following.

```bash

  gem install bow

```


## Usage

First of all. If you're not familiar with Rake and Rake tasks, take a look at
this pages: [Rake docs](https://ruby.github.io/rake/) and [Rake home](https://github.com/ruby/rake). It can be a good place to start from.


### Project structure

The basic bow project consists of two files: `Rakefile` and `targets.json`.

Run `bow init` which will generate an example project structure to give you a
basic understanding of how to write your own configuration.

Sometimes it can be convinient to put tasks to separate files into the
[rakelib](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Multiple+Rake+Files)
folder. So Rake will automatically autoload them.


**targets.json** contains a list of hosts grouped in categories:


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


**Rakefile** is actually an ordinary Rakefile) which contains several tasks
for provisioning packed in namespaces which are called by the name of the server
groups from the `targets.json` file.

The main task of the group MUST always be called **provision** and can be bound
to any number of additional tasks.


```ruby

require 'bow/rake'

Rake.application.options.trace_rules = true

PROVISION_DIR = '/tmp/rake_provision'.freeze

namespace :web do
  task provision: :print_hello do
  end

  flow run: :once
  task :print_hello do
    sh 'echo "Hello from example group #1 server!"'
  end
end

namespace :example_group2 do
  task provision: :print_hello do
  end

  # Change enabled value to "false" to run the reverting task (:print_goodbye)
  flow enabled: true, revert_task: :print_goodbye
  task :print_hello do
    sh 'echo "Hello from example group #2 server!"'
  end

  task :print_goodbye do
    sh 'echo "Goodbye! The task at example group #2 is disabled!"'
  end
end

```


### Commands


To **check the availability** of all configured hosts run:


```bash

  bow ping

```

To **prepare soft on client** needed for bow to run
(Ruby and 2 gems: rake and bow) execute

```bash

  bow prepare

```

To **apply configured provision** run:

```bash

  bow apply

```

To explore more options and commands run:

```bash

  bow -h

```


### Flow

Command **flow** from the upper example is a little extension added by the bow
gem which allows you to controll the flow of the task. It consists of 3 options:

* `run: :once` or `run: :always` sets the condition on how many times to run
the task;

* `enabled: true` or `enabled: false` wich takes a boolean value allows you to
disable the task so it can be ommited or reverted (if a reverting task
is given);

* `revert: task_name` wich defines a task that can revert changes done
by the original task when the original task is disabled (by `enabled: false`
option). Actually it's something similar to the down migration when dealing
with ActiveRecord;


### Run the example

To run the example locally this [Vagrantfile](doc/Vagrantfile) can be used to create a
testing environment.
