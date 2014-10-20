# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check to make sure proper env vars available
raise "Please set the DIGITALOCEAN_TOKEN env var." if ENV['DIGITALOCEAN_TOKEN'].nil?

# so we don't need to set the `--provider` flag for each command
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'digital_ocean'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "ostn-test"

  if Vagrant.has_plugin?("vagrant-digitalocean")
    config.vm.provider "digital_ocean" do |provider, override|
      provider.token = ENV['DIGITALOCEAN_TOKEN']
      provider.image = 'Debian 7.0 x64'
      provider.size = '512mb'
      provider.ssh_key_name = "#{Socket.gethostname}-digitalocean"

      override.ssh.private_key_path = '~/.ssh/id_rsa_do'
      override.vm.box = 'digital_ocean'
      override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    end
  end

  #config.vm.provision "shell",
  #  privileged: false,
  #  inline: "apt-get install sudo"

  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = "11.16.4"
    config.berkshelf.enabled = false

    config.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = ["cookbooks", "ext-cookbooks"]
      chef.add_recipe "apt"
      chef.add_recipe "postgresql::server"
      chef.add_recipe "postgresql::contrib"
      #chef.add_recipe "freeswitch"
      #chef.add_recipe "freeswitch::ivr"
      #chef.add_recipe "freeswitch::security"
      #chef.add_recipe "rbenv::default"
      #chef.add_recipe "rbenv::ruby_build"
      chef.add_recipe "webapp"
      #chef.add_recipe "kamailio::default"
      #chef.add_recipe "kamailio::postgresql_mod"

      # You may also specify custom JSON attributes:
      chef.json = {
        authorization: {
          sudo: {
            include_sudoers_d: true
          }
        },
        ostn: {
          github_user_access: "patcon",
        },
        postgresql: {
          password: {
            postgres: "testing123"
          }
        },
      }
    end
  end

end
