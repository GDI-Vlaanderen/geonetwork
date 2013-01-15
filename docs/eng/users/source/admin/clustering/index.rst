.. _clustering:

Clustering GeoNetwork
=============================

This section describes how you can cluster GeoNetwork for load-balancing and fail-over. To the outside world, the cluster appears as a single catalog. When one node goes down, it
will be automatically made up-to-date when it comes back up again.


Components
----------

The cluster contains 1 or more GeoNetwork nodes, each with their own Lucene index and (optionally) SVN version control. The database and the GeoNetwork data directory
are shared between all GeoNetwork nodes. Changes made in one of the GeoNetwork nodes are propagated to each of the other nodes using JMS; for this a JMS server
(ActiveMQ) is needed.

NOTE the dependency on ActiveMQ exists in only 1 line of code (creating a ConnectionFactory in class JMSActor); to use another JMS server it should suffice to adapt this line.

A diagram depicting an example cluster of 3 GeoNetwork nodes is this:

    .. figure:: cluster-components.png

        *A cluster with 3 GeoNetwork nodes*



Installation and Configuration
------------------------------

To install and configure the cluster you need to do the following:

(note: this list does not address installing and setting up your database)

- install ActiveMQ; if you wish to use fail-over for JMS, install it on more than one server; see http://activemq.apache.org/failover-transport-reference.html for information about how to use the client URL in that case.
- install the GeoNetwork nodes. These can be in the same or in different servlet containers, on the same or on different physical machines.
- install and configure a load-balancer that distributes requests between the GeoNetwork nodes. It should use sticky sessions, as the sessions are not shared between the GeoNetwork nodes.
- start ActiveMQ before starting or configuring the GeoNetwork nodes (if clustering is already configured and you start a GeoNetwork node when no JMS server is available, it will hang)
- configure each of the GeoNetwork nodes' JDBC connection so they use the same database (in WEB-INF/config.xml)
- configure directory paths for each of the GeoNetwork nodes in WEB-INF/web.xml. In a cluster you need to set the path to the data directory that's shared between the nodes, as well as paths
  to the directories for Lucene, SVN and cluster configuration which are local to each node.
- start each of the GeoNetwork nodes
- in any of the GeoNetwork nodes, log in as Administrator, go to System Configuration and set the URL(s) to the JMS server, and set clustering to Enabled. When you save these
  settings they're readily available to each of the other Geonetwork nodes, so you need to do it just once in one node.


Example configuration in web.xml
--------------------------------

Here's an example configuration in WEB-INF/web.xml for two nodes, showing the common data directory path and the node-local paths to Lucene, SVN and cluster config:

NODE 1:
++++++

::
    <servlet>
        <servlet-name>gn-servlet</servlet-name>
        <servlet-class>jeeves.server.sources.http.JeevesServlet</servlet-class>
        <!-- Specified what overrides to use if the (servlet.getServletContext().getServletContextName()).jeeves.configuration.overrides.file system parameter is not specified. -->
        <init-param>
            <param-name>jeeves.configuration.overrides.file</param-name>
            <param-value>,/WEB-INF/config-overrides-prod.xml</param-value>
        </init-param>

        <!-- Shared folder: common for all instances of the cluster. The folder stores schema plugins, logos -->
        <init-param>
            <param-name>geonetwork.dir</param-name>
            <param-value>/opt/gn_cluster/shared_data</param-value>
        </init-param>

        <!-- Local folders for each node:
            * lucene,
            * svn and
            * cluster configuration
        -->
        <init-param>
            <param-name>geonetwork.lucene.dir</param-name>
            <param-value>/opt/gn_cluster/node1/lucene</param-value>
        </init-param>
        <init-param>
            <param-name>geonetwork.svn.dir</param-name>
                <param-value>/opt/gn_cluster/node1/svn</param-value>
        </init-param>
        <init-param>
            <param-name>geonetwork.clusterconfig.dir</param-name>
            <param-value>/opt/gn_cluster/node1/cluster</param-value>
        </init-param>

        <load-on-startup>1</load-on-startup>
    </servlet>

NODE 2:
++++++

::

    <servlet>
        <servlet-name>gn-servlet</servlet-name>
        <servlet-class>jeeves.server.sources.http.JeevesServlet</servlet-class>
        <!-- Specified what overrides to use if the (servlet.getServletContext().getServletContextName()).jeeves.configuration.overrides.file system parameter is not specified. -->
        <init-param>
            <param-name>jeeves.configuration.overrides.file</param-name>
            <param-value>,/WEB-INF/config-overrides-prod.xml</param-value>
        </init-param>

        <!-- Shared folder: common for all instances of the cluster. The folder stores schema plugins, logos -->
        <init-param>
            <param-name>geonetwork.dir</param-name>
            <param-value>/opt/gn_cluster/shared_data</param-value>
        </init-param>

        <!-- Local folders for each node:
            * lucene,
            * svn and
            * cluster configuration
        -->
        <init-param>
            <param-name>geonetwork.lucene.dir</param-name>
            <param-value>/opt/gn_cluster/node2/lucene</param-value>
        </init-param>
        <init-param>
            <param-name>geonetwork.svn.dir</param-name>
            <param-value>/opt/gn_cluster/node2/svn</param-value>
        </init-param>
        <init-param>
            <param-name>geonetwork.clusterconfig.dir</param-name>
            <param-value>/opt/gn_cluster/node2/cluster</param-value>
        </init-param>

        <load-on-startup>1</load-on-startup>
    </servlet>


Monitoring
----------

You can monitor the sate of the JMS message exchanges using ActiveMQ (see http://activemq.apache.org/how-can-i-monitor-activemq.html).

A GeoNetwork cluster uses the following channels:

Topics (publish-subscribe):
++++++++++++++++++++++++++

Messages published to these topics are received by all nodes in the cluster. If a node is down, it will receive the messages
published during its absence when it comes back up, in correct order. When all nodes have read the message, it will be removed
from the topic (at some point).

- RE-INDEX
  Used to synchronize the nodes' Lucene indexes when metadata is added, deleted, updated, its privileges change, etc.

- OPTIMIZE-INDEX
  Used to propagate the Optimize Index command to all nodes.

- RELOAD-INDEX-CONF
  Used to propagate the Reload Index Configuration command to all nodes.

- SETTINGS
  Used to propagate a change in Settings to all nodes.

- ADD-THESAURUS

- DELETE-THESAURUS

- ADD-THESAURUS-ELEMENT

- UPDATE-THESAURUS-ELEMENT

- DELETE-THESAURUS-ELEMENT

- MD-VERSIONING
  Used to invoke the nodes' SVN versioning control.

- HARVESTER
  Used to propagate changes to Harvesters to all nodes.

- SYSTEM_CONFIGURATION
  Used to request all nodes to publish their System Information.

- SYSTEM_CONFIGURATION_RESPONSE
  Used to publish System Information.

Queues (point-to-point):
+++++++++++++++++++++++

Messages published to these queues are received by one single node in the cluster. This can be any one of the nodes, whichever
is first. When a node reads a message it is removed from the queue.

- HARVEST
  Used to run a Harvester. When clustering is enabled, a Harvester that's set to run periodically is invoked by periodic
  publication of a message to this queue; any one of the nodes in the cluster that picks it up first, will actually run
  the Harvester.