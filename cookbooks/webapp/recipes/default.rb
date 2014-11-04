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

# Install nginx site

include_recipe "nginx"

template "#{node['nginx']['dir']}/sites-available/ostn-staging-site" do
  source "nginx-site.erb"
  mode "0755"
  action :create
  notifies :restart, "service[nginx]"
end

nginx_site "ostn-staging-site" do
  enable true
end

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

github_user = node['ostn']['github_user_access']

remote_file "/home/#{DEPLOY_USER}/.ssh/authorized_keys" do
  source "https://github.com/#{github_user}.keys"
  owner DEPLOY_USER
  group DEPLOY_USER
  mode "0600"
end

# create postgres database

include_recipe 'postgresql::contrib' # required for dblink extension

bash "install-dblink-extension" do
  user "postgres"
  code "echo CREATE EXTENSION IF NOT EXISTS dblink | psql"
end

db_name = node[:ostn][:db_name]

db_sql_script = <<HEREDOC
DO
$do$
BEGIN

IF EXISTS (SELECT 1 FROM pg_database WHERE datname = '#{db_name}') THEN
   RAISE NOTICE 'Database already exists';
ELSE
   PERFORM dblink_exec('dbname=' || current_database() -- current db
                      , $$CREATE DATABASE #{db_name}$$);
END IF;

END
$do$
HEREDOC

file "/tmp/create-postgres-db.sql" do
  owner "postgres"
  group "postgres"
  content db_sql_script
end

bash "create-postgres-db" do
  user "postgres"
  code "psql < /tmp/create-postgres-db.sql"
end

# Create postgres user

user_sql_script = <<HEREDOC
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = '#{DEPLOY_USER}') THEN

      CREATE ROLE #{DEPLOY_USER} LOGIN ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';
      GRANT ALL PRIVILEGES ON DATABASE #{db_name} TO #{DEPLOY_USER};
   END IF;
END
$body$
HEREDOC

file "/tmp/create-postgres-user.sql" do
  owner "postgres"
  group "postgres"
  content user_sql_script
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

sudo 'kamailio-restart' do
  user DEPLOY_USER
  runas 'root'
  nopasswd true
  commands ['/usr/bin/service kamailio restart']
end

# Add unicorn_ostn init file

template "/etc/init.d/unicorn_ostn" do
  source "unicorn_init.sh.erb"
  mode "0755"
end

# Create ruby environment

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

# Speed up compilation during development
include_recipe "webapp::precompiled_ruby"

RB_VERS = "1.9.3-p547"

rbenv_ruby RB_VERS do
  global true
end

rbenv_gem "bundler" do
  ruby_version RB_VERS
end
