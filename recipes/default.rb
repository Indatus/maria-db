#include apt to get updated
include_recipe 'apt'


package "python-software-properties" do
    action :install
end


apt_repository 'mariadb-server' do
    uri          'http://ftp.kaist.ac.kr/mariadb/repo/5.5/ubuntu'
    distribution  'precise'
    components    ['main']
    keyserver    'hkp://keyserver.ubuntu.com:80'
    key          '0xcbcb082a1bb943db'
    deb_src      true
    notifies :run, resources(:execute => "apt-get update"), :immediately
end


#include build-essential for compiling C software
include_recipe 'build-essential'

maria_db_package_list = {
  'galera'                    => nil,
  'mariadb-galera-server-5.5' => nil,
  'mariadb-client-5.5'        => nil,
  'libmariadbclient18'        => nil,
  'mariadb-client-core-5.5'   => nil,
  'rsync'                     => nil,
  'netcat-openbsd'            => nil
}

#make installs non-interactive
ENV['DEBIAN_FRONTEND'] = "noninteractive"

maria_db_package_list.each do |pkg, ver|
    package pkg do
        version ver
        options "--force-yes"
        action :install
    end
end


apt_repository 'percona-repository' do
    uri          'http://repo.percona.com/apt'
    distribution  'precise'
    components    ['main']
    keyserver    'keys.gnupg.net'
    key          '1C4CBDCDCD2EFD2A'
    deb_src      true
    notifies :run, resources(:execute => "apt-get update"), :immediately
end


percona_package_list = {
  'percona-toolkit'    => nil,
  'percona-xtrabackup' => nil
}
percona_package_list.each do |pkg, ver|
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
  check_sql = %(SELECT User FROM mysql.user where User='#{node['mariadb']['replication_user']}';)
  command %(#{node['mariadb']['mysql_bin']} -u root -e "#{grant_sql}" --password=#{node['mariadb']['server_root_password']})
  action :run
  not_if %(#{node['mariadb']['mysql_bin']} -u root -e "#{check_sql}" --password=#{node['mariadb']['server_root_password']})
end

execute "assign-loadbalancer-password" do
  user_sql = %(INSERT INTO mysql.user (Host,User) values ('#{node['mariadb']['load_balancer_host']}','#{node['mariadb']['load_balancer_user']}'); FLUSH PRIVILEGES;)
  check_sql = %(SELECT Host,User FROM mysql.user where Host='#{node['mariadb']['load_balancer_host']}' AND User='#{node['mariadb']['load_balancer_user']}';)
  command %(#{node['mariadb']['mysql_bin']} -u root -e "#{user_sql}" --password=#{node['mariadb']['server_root_password']})
  action :run
  not_if %(#{node['mariadb']['mysql_bin']} -u root -e "#{check_sql}" --password=#{node['mariadb']['server_root_password']})
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


# template "/etc/mysql/conf.d/cluster.cnf" do
#   source "cluster.cnf.erb"
#   mode "644"
#   owner "root"
#   group "root"
#   #notifies :restart, "service[mysql]"
# end


template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  mode "644"
  owner "root"
  group "root"
  #notifies :restart, "service[mysql]"
end


template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  mode "644"
  owner "root"
  group "root"
  #notifies :restart, "service[mysql]"
end
