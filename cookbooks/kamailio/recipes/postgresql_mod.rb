#
# Cookbook Name:: kamailio
# Recipe:: postgresql_mod
#
# Copyright 2013, Lee Azzarello <lee@guardianproject.info>
#
# GPLv3
#

# Create kamalio postgres user

pg_user = 'kamailio'

user_sql_script = <<HEREDOC
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = '#{pg_user}') THEN

      CREATE ROLE #{pg_user} LOGIN ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';
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


# Set read-only access for kamailio user as default
# See: http://stackoverflow.com/a/762649/504018

bash "read-only-db-access-for-kamailio-user" do
  user "deploy"
  code "echo ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO #{pg_user} | psql -d #{node[:ostn][:db_name]}"
end

# install the kamailio driver
package "kamailio-postgres-modules"
