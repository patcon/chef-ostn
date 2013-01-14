#
# Cookbook Name:: ostn
# Recipe:: default
#
# Copyright 2012, Twelve Tone Software
#
# GPL version 2 placeholder
# https://www.gnu.org/licenses/gpl2.txt
#

package "readline6-dev"
gem_package "bundler"

# the freeswitch cookbook must be run before this resource
# get source
execute "git_clone" do
  command "git clone #{node[:ostn][:git_uri]}"
  cwd "/usr/local/src"
  creates "/usr/local/src/OSTel"
end

execute "bundle_install" do
	command "bundle install"
	cwd ""
	creates ""
end

# the postgresql cookbook must be run before this resource
execute "createdb" do
	command "rake db:create"
	cwd "#{node[:freeswitch][:homedir]}/#{node[:ostn][:webapp_dir]}"
end
