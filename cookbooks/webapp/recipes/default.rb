#
# Cookbook Name:: ostn
# Recipe:: default
#
# Copyright 2012, Twelve Tone Software
#
# GPL version 2 placeholder
# https://www.gnu.org/licenses/gpl2.txt
#

# Git required for Capistrano deploy

include_recipe "git"

# Install custom nginx

include_recipe "nginx"

# Set up Capistrano's deploy user

DEPLOY_USER = "deploy"

user DEPLOY_USER do
  supports manage_home: true
  comment "Capistrano deployment user"
  home "/home/#{DEPLOY_USER}"
  shell "/bin/bash"
end

directory "/home/#{DEPLOY_USER}/.ssh" do
  owner DEPLOY_USER
  group DEPLOY_USER
  mode "0700"
end

github_user = "patcon"

remote_file "/home/#{DEPLOY_USER}/.ssh/authorized_keys" do
  source "https://github.com/#{github_user}.keys"
  owner DEPLOY_USER
  group DEPLOY_USER
  mode "0600"
end

# Create postgres user

sql_script = <<HEREDOC
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = '#{DEPLOY_USER}') THEN

      CREATE ROLE #{DEPLOY_USER} LOGIN PASSWORD '#{node['postgresql']['password']['postgres']}';
      ALTER USER #{DEPLOY_USER} CREATEDB;
   END IF;
END
$body$
HEREDOC

file "/tmp/create-postgres-user.sql" do
  owner "postgres"
  group "postgres"
  content sql_script
end

bash "create-postgres-user" do
  user "postgres"
  code "psql < /tmp/create-postgres-user.sql"
end

# deploy user needs `service` on its PATH

link "/usr/bin/service" do
  to "/usr/sbin/service"
end

# Allow deploy user limited sudo access

include_recipe "sudo"

sudo 'nginx-reload' do
  user DEPLOY_USER
  runas 'root'
  nopasswd true
  commands ['/usr/bin/service nginx reload']
end

sudo 'unicorn-actions' do
  user DEPLOY_USER
  runas 'root'
  nopasswd true
  commands ['/usr/bin/service unicorn_ostn *']
end

# Add unicorn_ostn init file

template "/etc/init.d/unicorn_ostn" do
  source "unicorn_init.sh.erb"
  mode "0755"
end

# Create ruby environment

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

RB_VERS = "1.9.3-p547"

rbenv_ruby RB_VERS do
  global true
end

rbenv_gem "bundler" do
  ruby_version RB_VERS
end
