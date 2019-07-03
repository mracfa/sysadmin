echo
echo $(date)" Setting environment"
echo


export JAVA_HOME={{ item.0.fmw_home.java.base_directory }}/{{ wls_java_home_prefix }}{{ item.0.fmw_home.java.version }}
export MW_HOME={{ item.0.fmw_home.oracle_home }}
export WL_HOME=$MW_HOME/wlserver
. $WL_HOME/server/bin/setWLSEnv.sh


WLS_ADMIN={{ wcs_admin_username }}
WLS_PASSWORD={{ item.0.admin_password }}
WLS_HOST={{ item.0.servers.admin.listen_address }}
WLS_PORT={{ (item.0.servers.admin.administration_port if item.0.servers.admin.administration_port is defined else item.0.administration_port) if item.0.administration_port_enabled else item.0.servers.admin.listen_port }}

(
cat << EOF
from weblogic.descriptor import BeanAlreadyExistsException
from java.lang.reflect import UndeclaredThrowableException
from java.lang import System
import javax
from javax import management
from javax.management import MBeanException
from javax.management import RuntimeMBeanException
import javax.management.MBeanException
from java.lang import UnsupportedOperationException
from javax.management import InstanceAlreadyExistsException
from java.lang import Exception
from jarray import array


print "Trying to connect to the server ... "
connect("$WLS_ADMIN","$WLS_PASSWORD","t3s://$WLS_HOST:$WLS_PORT")
if connected=='false':
  stopExecution('You need to be connected.')

edit()
startEdit()

cd('/JMSServers/WCSVSJMSServer_auto_1')
set('Targets',jarray.array([], ObjectName))

{% for server in item.0.servers.sites_secondary %}
cd('/JMSServers/WCSVSJMSServer_auto_{{ loop.index+1 }}')
set('Targets',jarray.array([], ObjectName))
{% endfor %}

cd('/JDBCStores/WCSVSJMSJDBCStore')
cmo.setDataSource(getMBean('/JDBCSystemResources/wcsitesVisitorsDS'))
set('Targets',jarray.array([ObjectName('com.bea:Name={{ item.0.clusters.visitor.name }},Type=Cluster')], ObjectName))

cd('/FileStores/WCSVSJMSFileStore_auto_1')
set('Targets',jarray.array([], ObjectName))

{% for server in item.0.servers.sites_secondary %}
cd('/FileStores/WCSVSJMSFileStore_auto_{{ loop.index+1 }}')
set('Targets',jarray.array([], ObjectName))
{% endfor %}

cd('/')
cmo.createJMSServer('JMSServer-0')

cd('/JMSServers/JMSServer-0')
cmo.setPersistentStore(getMBean('/JDBCStores/WCSVSJMSJDBCStore'))
set('Targets',jarray.array([ObjectName('com.bea:Name={{ item.0.clusters.visitor.name }},Type=Cluster')], ObjectName))

cd("/JMSSystemResources/WCSVSJMSModule/Resource/WCSVSJMSModule/UniformDistributedQueues/dist_wcsitesVisitorsUpdateQueue_auto")
deploy_name = cmo.getSubDeploymentName()
cd("/JMSSystemResources/WCSVSJMSModule/SubDeployments")
cd(deploy_name)
set('Targets',jarray.array([ObjectName('com.bea:Name=JMSServer-0,Type=JMSServer')], ObjectName))

cd('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule')
cmo.destroyUniformDistributedQueue(getMBean('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule/UniformDistributedQueues/dist_wcsitesVisitorsEnrichQueue_auto'))
cmo.destroyUniformDistributedQueue(getMBean('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule/UniformDistributedQueues/dist_wcsitesVisitorsUpdateQueue_auto'))
cmo.createUniformDistributedQueue('wcsitesVisitorsEnrichQueue')

cd('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule/UniformDistributedQueues/wcsitesVisitorsEnrichQueue')

cmo.setJNDIName('jms/wcsitesVisitorsEnrichQueue')
cmo.setDefaultTargetingEnabled(true)

cd('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule')
cmo.createUniformDistributedQueue('wcsitesVisitorsUpdateQueue')

cd('/JMSSystemResources/WCSVSJMSModule/JMSResource/WCSVSJMSModule/UniformDistributedQueues/wcsitesVisitorsUpdateQueue')
cmo.setJNDIName('jms/wcsitesVisitorsUpdateQueue')
cmo.setDefaultTargetingEnabled(true)

cd('/')
cmo.destroyJMSServer(getMBean('/JMSServers/WCSVSJMSServer_auto_1'))
cmo.destroyFileStore(getMBean('/FileStores/WCSVSJMSFileStore_auto_1'))

{% for server in item.0.servers.sites_secondary %}
cmo.destroyJMSServer(getMBean('/JMSServers/WCSVSJMSServer_auto_{{ loop.index+1 }}'))
cmo.destroyFileStore(getMBean('/FileStores/WCSVSJMSFileStore_auto_{{ loop.index+1 }}'))
{% endfor %}


startEdit()
save()
activate(block="true")


EOF
) > new_conf.py

java -Djava.security.egd=file:///dev/./urandom weblogic.WLST new_conf.py

echo
echo $(date)" End"

