#include apt to get updated
include_recipe 'apt'

package "python-software-properties" do
    action :install
end

apt_repository 'mariadb-server' do
  uri          'http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu'
  distribution  'precise'
  components    ['main']
  keyserver    'hkp://keyserver.ubuntu.com:80'
  key          '0xcbcb082a1bb943db'
  deb_src      false
end

#include build-essential for compiling C software
include_recipe 'build-essential'

case node['platform_family']
  when "debian"
    package_list = ['mariadb-galera-server', 'galera']
end

package_list.each do |pkg|
  package pkg do
    action :install
  end
end