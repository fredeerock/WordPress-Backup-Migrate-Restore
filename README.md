# WordPress Backup/Migrate/Restore Guide

## Backup WordPress. 

Find the db-host, db-username, and db-name from wp-config.php. While there note the table_prefix value. 
`mysqldump --column-statistics=0 -h <db-host> -u <db-username> -p <db-name> | tar -cvzf wordpressdb.sql.tar.gz`

Archive the whole WordPress file direcotry.
  `tar -czvf <wordpress-dir> wordpressfiles.tar.gz`

Move these 2 files somwhere safe.

## Migrate to new WordPress Install and DB

Let's use Docker as an example, but this should work for other servers as well.
- `docker run -v ~/lamp:/root -p 8082:80 -t -i linode/lamp /bin/bash`
- `apt-get install php5-mysqlnd`
- `service apache2 start`
- `service mysql start`

*The password for this mysql db is `Admin2015`.*

Create DB and DB user on new server.
- `mysql -u root -p`
- `CREATE DATABASE wordpress;`
- `CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'Admin2015';`
- `GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';`

## Restore WordPress.

Move `wordpressfiles.tar.gz` and `wordpressdb.sql.tar.gz` to new server.

Change directory over to where your sites contents are being served. For example:
- `cd /var/www/example.com/public_html`

Uncompress the sql backup file. 
- `tar -xvzf wordpressdb.sql.tar.gz`

Import the the database tables. Added tcp protocol for Docker compatability.
- `mysql -h <db-host> -P <port-number> --protocol=tcp -u wordpress -p wordpress < wordpressdb.sql`

If you get a collation error, try:
- `sed -i -e 's/utf8mb4_unicode_520_ci/utf8mb4_unicode_ci/g' wordpressDbBackup.sql`

Change domain name:
- `mysql -u root -p`
- `use wordpress`
- `show tables;`
- Double check old domain name. You may need to change table prefix.
- `select * from wp_options where option_id = 1;`
- `select * from wp_options where option_id = 2;`
- `select * from wp_options where option_value = ‘http://www.olddomain.com/wordpress’;`
- Set the new domain name
- `update wp_options set option_value = ‘http://www.newdomain.com’ where option_id = 1;`
- `update wp_options set option_value = ‘http://www.newdomain.com’ where option_id = 2;`

Sometimes there are prefix issues if there's an existing wp install. Updating the prefix can help:
- ``UPDATE `newprefix_usermeta` SET `meta_key` = REPLACE( `meta_key` , 'oldprefix_', 'newprefix_' );``

Permalinks can be updated by going into 
- `WP Dashboard > Settings > Permalinks > Pressing Save`