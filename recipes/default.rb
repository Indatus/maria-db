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
    deb_src      true
end

apt_preference 'mariadb.pref' do
    glob         '*'
    pin          'origin http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu'
    pin_priority '1000'
end

#include build-essential for compiling C software
include_recipe 'build-essential'

package_list = {
    'libmysqlclient18' => '5.5.33a+maria-1~precise',
    'mysql-common' => '5.5.33a+maria-1~precise',
    'mariadb-galera-server' => nil,
    'galera' => nil   
}

package_list.each do |pkg, ver|
    package pkg do
        version ver
        action :install
    end
end