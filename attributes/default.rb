default['mariadb']['cluster_nodes']                 = ""
default['mariadb']['mysqladmin_bin']                = "/usr/bin/mysqladmin"
default['mariadb']['mysql_bin']                     = "/usr/bin/mysql"
default['mariadb']['server_root_password']          = ""
default['mariadb']['replication_user']              = "replication-user"
default['mariadb']['replication_password']          = "password"
default['mariadb']['maint_password']                = "password"
default['mariadb']['load_balancer_user']            = "balancer-user"
default['mariadb']['load_balancer_host']            = "host"
default['mariadb']['replication_password']          = "password"
default['mariadb']['cluster_name']                  = "glaera-cluster"

#tuning
default['mariadb']['slow_query_log']                = '0'
default['mariadb']['slow_query_log_file']           = '/var/log/mysql/mariadb-slow.log'
default['mariadb']['long_query_time']               = '0'
default['mariadb']['log_queries_not_using_indexes'] = '0'
default['mariadb']['connect_timeout']               = '5'
default['mariadb']['allow_remote_root']             = false
default['mariadb']['grants_path']                     = "/etc/mysql/grants.sql"