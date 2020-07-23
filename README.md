# postgres_historical_data

1) Install Stack Builder on the Database Server.
2) Using Stack Builder, install PgAgent.

# Backups from linux

sudo su - postgres
pg_dump database_name > BACK_20191125_database_name.sql

# Restore from backup

sudo su - postgres
psql -f /home/create_databases.sql

psql -d database1 -f /home/BACK_20191125_database1.sql
psql -d database2 -f /home/BACK_20191125_database2.sql
psql -d database3 -f /home/BACK_20191125_database3.sql

Credits to Gustavo Rolla.
