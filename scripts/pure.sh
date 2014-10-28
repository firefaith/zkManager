# Only follow symlinks if readlink supports it
if readlink -f "$0" > /dev/null 2>&1
then
  ZOOBIN=`readlink -f "$0"`
else
  ZOOBIN="$0"
fi
ZOOBINDIR=`dirname "$ZOOBIN"`

. "$ZOOBINDIR"/zkEnv.sh

ZOODATADIR=$(grep "^[[:space:]]*dataDir=" "$ZOOCFG" | sed -e 's/.*=//')
ZOODATALOGDIR=$(grep "^[[:space:]]*dataLogDir=" "$ZOOCFG" | sed -e 's/.*=//')

if [ "x$ZOODATALOGDIR" = "x" ]
then
$JAVA "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \
     -cp "$CLASSPATH" $JVMFLAGS \
     org.apache.zookeeper.server.PurgeTxnLog "$ZOODATADIR" $*
else
$JAVA "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \
     -cp "$CLASSPATH" $JVMFLAGS \
     org.apache.zookeeper.server.PurgeTxnLog "$ZOODATALOGDIR" "$ZOODATADIR" $*
fi

