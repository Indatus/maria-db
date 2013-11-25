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


apt_repository 'percona-repository' do
    uri          'http://repo.percona.com/apt'
    distribution  'precise'
    components    ['main']
    keyserver    'keys.gnupg.net'
    key          '1C4CBDCDCD2EFD2A'
    deb_src      true
end


#include build-essential for compiling C software
include_recipe 'build-essential'


# package_list = {
#     'libmysqlclient18'      => nil, #'5.5.33a+maria-1~precise',
#     'mysql-common'          => nil, #'5.5.33a+maria-1~precise',
#     'mariadb-galera-server' => nil,
#     'galera'                => nil,
#     'percona-toolkit'       => nil,
#     'percona-xtrabackup'    => nil 
# }
package_list = {
    'libmysqlclient18'      => "5.5.34+maria-1~precise",
    'mariadb-galera-server' => "5.5.33a+maria-1~precise",
    'galera'                => nil,
    'percona-toolkit'       => nil,
    'percona-xtrabackup'    => nil 
}

#make installs non-interactive
ENV['DEBIAN_FRONTEND'] = "noninteractive"


package_list.each do |pkg, ver|
    package pkg do
        version ver
        options "--force-yes"
        action :install
    end
end


execute "assign-root-password" do
  command "\"#{node['mariadb']['mysqladmin_bin']}\" -u root password \"#{node['mariadb']['server_root_password']}\""
  action :run
  only_if "\"#{node['mariadb']['mysql_bin']}\" -u root -e 'show databases;'"
end

execute "assign-replication-password" do
  grant_sql = %(GRANT ALL PRIVILEGES ON *.* to '#{node['mariadb']['replication_user']}'@'%' IDENTIFIED BY '#{node['mariadb']['replication_password']}';)
  command %(#{node['mariadb']['mysql_bin']} -u root -e "#{grant_sql}" --password=#{node['mariadb']['server_root_password']})
  action :run
end

execute "assign-loadbalancer-password" do
  user_sql = %(USE mysql; INSERT INTO user (Host,User) values ('#{node['mariadb']['load_balancer_host']}','#{node['mariadb']['load_balancer_user']}'); FLUSH PRIVILEGES;)
  command %(#{node['mariadb']['mysql_bin']} -u root -e "#{user_sql}" --password=#{node['mariadb']['server_root_password']})
  action :run
  not_if %(#{node['mariadb']['mysql_bin']} -u root -e "select User,Host from mysql.user where Host='#{node['mariadb']['load_balancer_host']}' AND User='#{node['mariadb']['load_balancer_user']}';" --password=#{node['mariadb']['server_root_password']})
end



service "mysql" do
  supports(
    :start => true,
    :stop => true, 
    :restart => true,
    :reload => true,
    :status => true
  )
  action :enable
end


template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  mode "644"
  owner "root"
  group "root"
  #notifies :restart, "service[mysql]"
end
