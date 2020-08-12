#!/bin/bash

OUTPUT_DIR=/opt/circonus/agent/cache
OUTPUT_FILE=$OUTPUT_DIR/cpkg.list
SUPPRESS_FILE=$OUTPUT_DIR/cpkg.wip
CACHE_MINUTES=5

suppressions() {
    if [[ -r $SUPPRESS_FILE ]]; then
        while read -r line || [[ -n "$line" ]]; do
            pkg=`echo $line | awk -F= '{print $1;}'`
            user=`echo $line | awk -F= '{if($2) {print $2;} else { print "unspecified"; }}'`
            printf "%s\ts\twip:%s\n" $pkg $user
        done < $SUPPRESS_FILE
    fi
}

if [[ ! -d $OUTPUT_DIR ]]; then
    echo "error\ts\tbad cache directory"
    OUTPUT_FILE=/dev/null
else
    find $OUTPUT_FILE -mmin +$CACHE_MINUTES -exec rm {} \; 2>/dev/null
    if [[ -r $OUTPUT_FILE ]]; then
        LMOD=`/bin/stat -c "%Y" $OUTPUT_FILE`
        CTIME=`/bin/date +%s`
        ((AGE=$CTIME-$LMOD))
        printf "cached\tl\t%d\n" $AGE
        cat $OUTPUT_FILE
        suppressions
        exit
    fi
    if [[ ! -w $OUTPUT_FILE ]]; then
        if ! touch $OUTPUT_FILE 2> /dev/null; then
            echo "error\ts\tcannot create cache file"
            OUTPUT_FILE=/dev/null
        fi
    fi
fi

case `uname -s` in
    Linux)
        if [[ -f /etc/redhat-release ]]; then
            # RHEL/CentOS
            /bin/rpm -qa --queryformat '%{NAME}\ts\t%{VERSION}-%{RELEASE}\n' 'circonus*' | /usr/bin/tee $OUTPUT_FILE
        elif [[ -f /etc/lsb-release ]]; then
            # Debian/Ubuntu
            /usr/bin/dpkg-query --show --showformat '${Package}\ts\t${Version}\n' 'circonus*' | /usr/bin/tee $OUTPUT_FILE
        else
            echo "error\ts\tunsuported Linux distro"
        fi
        suppressions
        ;;
    *)
        echo "error\ts\tunsuported platform"
        exit
        ;;
esac

