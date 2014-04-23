default['mariadb']['cluster_nodes']                 = ""
default['mariadb']['mysqladmin_bin']                = "/usr/bin/mysqladmin"
default['mariadb']['mysql_bin']                     = "/usr/bin/mysql"
default['mariadb']['server_root_password']          = ""
default['mariadb']['replication_user']              = "***REMOVED***"
default['mariadb']['replication_password']          = "***REMOVED***"
default['mariadb']['maint_password']                = "***REMOVED***"
default['mariadb']['load_balancer_user']            = "balance"
default['mariadb']['load_balancer_host']            = "%"
default['mariadb']['replication_password']          = "***REMOVED***"
default['mariadb']['cluster_name']                  = "my_galera_cluster"

#tuning
default['mariadb']['slow_query_log']                = '0'
default['mariadb']['slow_query_log_file']           = '/var/log/mysql/mariadb-slow.log'
default['mariadb']['long_query_time']               = '0'
default['mariadb']['log_queries_not_using_indexes'] = '0'