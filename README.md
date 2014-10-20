# OSTN

This project aims to make deployment of an OSTN server and accompanying
Ruby on Rail webapp possible in several commands.

This project will provision the server on DigitalOcean. It will then be
ready for using the seperate OSTel repository to deploy the webapp.

After provisioning the server, please see this repo for instructions on
deploying the Rails webapp:

    https://github.com/patcon/OSTel#readme

## Requirements

- Vagrant
- Chefdk
- vagant-digitalocean plugin: `vagrant plugin install vagrant-digitalocean`
- DigitalOcean API key: `export DIGITALOCEAN_TOKEN=<my_api_key>`

## Usage

**See Caveats section first.**

From the project folder, run these commands:

```
berks vendor ext-cookbooks
vagrant up
```

### Caveats

- My github username is hardcoded to give me access, so [edit
  this.](https://github.com/patcon/chef-ostn/blob/easier-deploy/cookbooks/webapp/recipes/default.rb#L36)

- You'll likely need to add this to your local `/etc/hosts` file:

        # replace IP with server IP from `vagrant ssh-config` command
        123.1.2.3 ostn-test

