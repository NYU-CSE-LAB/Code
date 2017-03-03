# create_postgresql.sh BATCH_FILE
# file input: email pass first last

# Set Postgres user and password envs
#export PGPASSWORD=password
#export PGUSER=postgres
#export PGPORT=5432
source ~/.bashrc
# Student Input List
STUDENTS=/root/list_postgres

cat $STUDENTS | while read line; do
	user=`echo $line | awk -F@ '{print $1}'`
        pass=`echo $line | awk '{print $2}'`
        full_name=`echo $line | awk '{print $3, $4}'`

# Check if user and database already exist 
ISUSER="$(psql -U postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$user';")"
ISDB="$(psql -U postgres -tAc "SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower('$user');")"

if [ "$ISUSER" = "1" ] && [ "$ISDB" ];then
	echo "User and database both exist."
elif [ "$ISUSER" = "1" ];then
	echo "Only User exists, not the database."
	echo "Creating the database:$user, granting $user ALL PRIVILEGES."
        psql -U postgres -tAc "CREATE DATABASE $user;"
        psql -U postgres -tAc "GRANT ALL PRIVILEGES ON DATABASE "$user" to $user;"
        psql -U postgres -tAc "REVOKE connect ON DATABASE $user FROM PUBLIC;"
elif [ "$ISDB" ];then
	echo "Only database exists."
	echo "Creating the user and granting all priviledge to database:$user."
        psql -U postgres -tAc "CREATE USER $user WITH PASSWORD '$pass';"
        psql -U postgres -tAc "GRANT ALL PRIVILEGES ON DATABASE "$user" to $user;"
else
	echo "Neither the user nor the database exist."
        psql -U postgres -tAc "CREATE DATABASE $user;"
        psql -U postgres -tAc "CREATE USER $user WITH PASSWORD '$pass';"
        psql -U postgres -tAc "GRANT ALL PRIVILEGES ON DATABASE "$user" to $user;"
        psql -U postgres -tAc "REVOKE connect ON DATABASE $user FROM PUBLIC;"
fi
# END WHITE LOOP
done
