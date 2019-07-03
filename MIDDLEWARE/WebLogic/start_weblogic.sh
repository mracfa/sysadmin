#!/bin/sh
#
# <domain> domain startup/stop script.
#
# description: Script for starting and stopping the AdminServer for domain <domain>.
#


DOMAIN="$1"
LOGS_PATH="/weblogic/${DOMAIN}/servers/${DOMAIN}AdminServer/logs/"
DOMAIN_PATH="/weblogic/${DOMAIN}"
WLSUSER="weblogic"


get_pids()
{
  ps -ef | grep java | grep -v grep | grep -i ${DOMAIN} | grep -i adminserver | awk '{print($2)}'
}


start_admin()
{
  cd ${LOGS_PATH}
  su -c "((nohup ${DOMAIN_PATH}/bin/startWebLogic.sh &>nohup.out) &)" ${WLSUSER}
}


start()
{
  PIDS="`get_pids`"


  if [ -z "${PIDS}" ]; then
    if [ -f "${LOGS_PATH}/nohup.out" ]; then
      mv "${LOGS_PATH}/nohup.out" "${LOGS_PATH}/nohup.out.`date +%d%m%Y%H%M%S`"
    fi
    echo "Starting AdminServer for domain ${DOMAIN}..."
    start_admin
  else
    echo "AdminServer for domain ${DOMAIN} appears to be already running with pids "${PIDS}"."
  fi
}


stop()
{
  PIDS="`get_pids`"


  if [ ! -z "${PIDS}" ]; then
    echo "Going to kill pids "${PIDS}"..."


    kill -9 `echo ${PIDS}`


    PIDS="`get_pids`"


    if [ -z "${PIDS}" ]; then
      echo "AdminServer for domain ${DOMAIN} sucessfully stopped."
    else
      echo "Unable to stop AdminServer for domain ${DOMAIN}."
    fi
  else
    echo "AdminServer for domain ${DOMAIN} appears to be stopped."
  fi
}


status()
{
  PIDS="`get_pids`"


  if [ ! -z "${PIDS}" ]; then
    echo "AdminServer for domain ${DOMAIN} is running with pids "${PIDS}
  else
    echo "AdminServer for domain ${DOMAIN} appears to be stopped."
  fi
}


# See how we were called.


case "$2" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        start
        ;;
  status)
        status
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac
exit 0
