default[:ostn][:webapp_dir] = "/home/deploy/ostn/current"
default[:ostn][:db_name] = "ostn_staging"
# The :nginx_strict_ssl will disable support for older browsers like IE6.
# See note here: https://dev.guardianproject.info/projects/ostel/wiki/Nginx
default[:ostn][:nginx_strict_ssl] = true
