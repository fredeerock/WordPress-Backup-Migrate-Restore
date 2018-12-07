# WordPress Backup/Migrate/Restore Guide

## Backup WordPress. 

Find the db-host, db-username, and db-name from wp-config.php. While there note the table_prefix value. 
- `mysqldump --column-statistics=0 -h <db-host> -u <db-username> -p <db-name> | gzip > wordpressdb.sql.gz`

Archive the whole WordPress file direcotry.
- `tar -czvf wordpressfiles.tar.gz <wordpress-dir>`

Move these 2 files somwhere safe.

## Migrate to new WordPress Install and DB

Let's use Docker as an example, but this should work for other servers as well.
- `docker run -v ~/Desktop:/root -p 8082:80 -p 3307:3306 -t -i linode/lamp /bin/bash`
- `apt-get install php5-mysqlnd`
- `service apache2 start && service mysql start`

Create DB and DB user on new server.
- `mysql -u root -p`
- *The password for this mysql db is `Admin2015`.*
- `CREATE DATABASE wordpress;`
- `CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'Admin2015';`
- `GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';`
- For Docker: 
  - `CREATE USER 'wordpress'@'%' IDENTIFIED BY 'Admin2015';`
  - `GRANT ALL ON *.* TO 'wordpress'@'%';`

## Restore WordPress.

Move `wordpressfiles.tar.gz` and `wordpressdb.sql.gz` to new server.

Uncompress the sql backup file. 
- `tar -xvzf wordpressfiles.tar.gz`
- `gzip -d wordpressdb.sql.gz`

Import the the database tables. Added tcp protocol if you're connecting from a Docker host to a container.
- `mysql -h <db-host> -P <port-number> --protocol=tcp -u wordpress -p wordpress < wordpressdb.sql`
- For example: `mysql -u root -p wordpress < wordpressdb.sql`
- If you get a collation error, try: `sed -i -e 's/utf8mb4_unicode_520_ci/utf8mb4_unicode_ci/g' wordpressdb.sql`

Move extracted WordPress files to where your sites contents are being served. For example:
- `cp -R . /var/www/example.com/public_html`
- `cd /var/www/example.com/public_html/`
- `mv index.html index.html.old`

Change domain name:
- `mysql -u root -p`
- `USE wordpress`
- `SHOW tables;`
- Make a note of the table prefix, wp vs wpy8 etc.
- Find places where old domain name exists. You may need to change table prefix.
  - `select * from wp_options where option_value = ‘http://www.olddomain.com/wp’;`
- Set the new domain name
  - `update wp_options set option_value = ‘http://127.0.0.1:8082’ where option_name = 'siteurl';`
  - `update wp_options set option_value = ‘http://127.0.0.1:8082’ where option_name = 'home';`

Change wp-config.
- change `wp-config.php` settings to match.

Permalinks can be updated by going into 
- `WP Dashboard > Settings > Permalinks > Pressing Save`

### Notes

Sometimes there are prefix issues if there's an existing wp install. Updating the prefix can help:
- ``UPDATE `newprefix_usermeta` SET `meta_key` = REPLACE( `meta_key` , 'oldprefix_', 'newprefix_' );``

