ruby_tarball_path = "#{Chef::Config['file_cache_path']}/ruby-1.9.3.tgz"

remote_file ruby_tarball_path do
  source "https://s3.amazonaws.com/pkgr-buildpack-ruby/current/debian-7/ruby-1.9.3.tgz"
end

ruby_path = "#{node[:rbenv][:root_path]}/versions/1.9.3-p547"

directory ruby_path do
  owner node[:rbenv][:user]
  group node[:rbenv][:group]
  action :create
end

bash "install-precompiled-ruby" do
  user node[:rbenv][:user]
  group node[:rbenv][:group]
  cwd ruby_path
  code "tar -xzf #{ruby_tarball_path}"
end
