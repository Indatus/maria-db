name             'maria-db'
maintainer       'Indatus'
maintainer_email 'bwebb@indatus.com'
license          'All rights reserved'
description      'Installs/Configures maria-db cluster node'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends          'apt'
depends          'build-essential'
depends          'mysql::client'

recipe "maria-db", "and configures MariaDB cluster node"

%w{ debian ubuntu }.each do |os|
  supports os
end
