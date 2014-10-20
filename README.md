# OSTN Server

This project aims to make deployment of an OSTN server and accompanying
Ruby on Rail webapp possible in several commands.

This project will provision the server on DigitalOcean. It will then be
ready for using the seperate OSTel repository to deploy the webapp.

After provisioning the server, please see this repo for instructions on
deploying the Rails webapp:

    https://github.com/patcon/OSTel#readme

## Requirements

- [Vagrant](http://www.vagrantup.com/downloads.html)
- [ChefDK](https://downloads.getchef.com/chef-dk/) (temporary requirement)
- [DigitalOcean API
  key](https://cloud.digitalocean.com/settings/applications): `export
  DIGITALOCEAN_TOKEN=<my_api_key>`
- vagant-digitalocean plugin: `vagrant plugin install vagrant-digitalocean`

## Usage

**See Caveats section first.**

From the project folder, run these commands:

```
berks vendor ext-cookbooks # temporary step
vagrant up
```

Now that the server is up and running, clone the OSTel repo from the
link above and follow the deploy instructions for that webapp.

### Caveats

- My github username is hardcoded to give me access, so [edit
  this.](https://github.com/patcon/chef-ostn/blob/easier-deploy/cookbooks/webapp/recipes/default.rb#L36)

- You'll likely need to add this to your local `/etc/hosts` file:

        # find IP from `vagrant ssh-config` after `vagrant up`
        <server_ip> ostn-test

- Finally, NOT YET GUARANTEED TO WORK. I'll mark a release when this
  setup works consistently :)

