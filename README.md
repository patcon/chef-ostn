# OSTN

This project aims to make deployment of an OSTN server and accompanying
Ruby on Rail webapp possible in several commands.

This project will provision the server on DigitalOcean. It will then be
ready for using the seperate OSTel repository to deploy the webapp.

## Requirements

- Vagrant
- Chefdk
- vagant-digitalocean plugin: `vagrant plugin install vagrant-digitalocean`
- DigitalOcean API key: `export DIGITALOCEAN_TOKEN=<my_api_key>`

## Usage

From the project folder, run these commands:

```
berks vendor ext-cookbooks
vagrant up
```
