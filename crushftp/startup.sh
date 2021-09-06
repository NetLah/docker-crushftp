#!/usr/bin/env bash
cat >/etc/motd <<EOL
   ___             _    ___ _____ ___   _  __  
  / __|_ _ _  _ __| |_ | __|_   _| _ \ / |/  \ 
 | (__| '_| || (_-< ' \| _|  | | |  _/ | | () |
  \___|_|  \_,_/__/_||_|_|   |_| |_|   |_|\__/ 

CrushFTP 10, Alpine 3.13, OpenJDK 17
Build Time: `cat /tmp/__builddate.txt`
Start Time: `date '+%F %T %Z'`
EOL
cat /etc/motd

CRUSH_DIR="/var/opt/crushftp"

log() {
    echo "$(date '+%FT%T%z') $@"
}

log_n() {
    echo -n "$(date '+%FT%T%z') $@"
}

log "Initializing..."

if [[ ! -d $CRUSH_DIR ]] ; then
    log Create application folder $CRUSH_DIR...
    mkdir $CRUSH_DIR
fi

cd $CRUSH_DIR

if [[ ! -f CrushFTP.jar ]] ; then
    log "Copy source application..."
    unzip -oq $SOURCE_ZIP
    cp /tmp/__version.txt WebInterface/
fi

if [ -z "$ADMIN_USER" ]; then
    ADMIN_USER=crushadmin
fi

if [[ ! -d "users/MainUsers/$ADMIN_USER" ]] || [[ ! -f admin_user_set ]] ; then
    log "Creating admin user $ADMIN_USER..."

    if [[ -z "$ADMIN_PASSWORD" ]] ; then
        ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    fi

    log_n "" 
    java -jar CrushFTP.jar -a "$ADMIN_USER" "$ADMIN_PASSWORD"
    touch admin_user_set
else
    ADMIN_PASSWORD="****************"
fi

log_n "Starting CrushFTP... "
java -Xmx512m -jar $CRUSH_DIR/CrushFTP.jar -d & >/dev/null 2>&1
echo OK

log "Waiting server starting..."

until [ -f prefs.XML ]
do
    sleep 1
done

echo "########################################"
echo "# Started:    $(date '+%FT%T%z')"
echo "# User:       $ADMIN_USER"
echo "# Password:   $ADMIN_PASSWORD"
echo "########################################"

get_pid() {
    CRUSH_PID="`ps -a | grep "java" | grep "$CRUSH_DIR/CrushFTP.jar" | awk '{print $1}'`"
}

#get_pid
#log PID $CRUSH_PID has been started!

# SIGTERM-handler
term_handler() {
    log "Stopping..."
    get_pid
    #echo "CRUSH_PID:  $CRUSH_PID"
    if [[ -z "$CRUSH_PID" ]]; then    
        log Cannot find PID
        exit 1
    fi

    log_n "Shutting down CrushFTP... "
    kill $CRUSH_PID
    ret_val=$?
    if [ ${ret_val} -ne 0 ]; then
        echo FAIL
        log "Could not kill PID"
        exit 1
    fi 
    
    echo OK
    log "Stopped."
    exit 0
}

trap 'term_handler' SIGTERM

while true
do
    sleep 60m &
    wait $!
done
