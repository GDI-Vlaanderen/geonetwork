.. _advanced_configuration:
.. include:: ../../../substitutions.txt
.. _admin_how_to_config_db:

Configurer la base de données
=============================

Le catalogue utilise par défaut la base de données (ie. `H2 <http://www.h2database.com/>`_).

Les bases de données actuellement supportées sont les suivantes 
 (ordre alphabétique):

* DB2
* H2
* Mckoi
* MS SqlServer 2008
* MySQL
* Oracle
* PostgreSQL (ou PostGIS)


Configuration simple
--------------------

La connexion à la base de données est définie dans la section *<resources>* du fichier *web/geonetwork/WEB-INF/config.xml*.

Modifier l'attribut *enable* pour activer l'une des connexions. Il n'est pas possible d'activer deux connexions.::

	<resource enabled="true">
		...
		
Une fois activé, configurer :
 
- l'utilisateur, 

- le mot de passe

- le driver (utiliser les exemples fournis dans le fichier)

- l'url de connexion


Exemple d'une configuration pour utiliser PostGIS::

		<resource enabled="true">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>www-data</user>
				<password>www-data</password>
				<driver>org.postgresql.Driver</driver>
				<url>jdbc:postgis://localhost:5432/geonetwork</url>
			</config>
		</resource>



Pool de connexions
------------------

Le catalogue supporte 2 types de pool de connexion:

* Jeeves DbmsPool
* `Apache DBCP pool <http://commons.apache.org/dbcp/>`_ (recommandé à partir des versions 2.7.x)

Les paramètres suivants permettent une configuration fine du pool:

* poolSize
* maxTries
* maxWait


.. TODO Add more details about poolsize, maxWait, ...




Drivers JDBC
````````````
Les fichiers jar des drivers JDBC  doivent être dans le répertoire **GEONETWERK_INSTALL_DIR/WEB-INF/lib**. 
Pour les bases de données Open Source, comme MySQL et PostgreSQL, ces fichiers sont déjà installés. 
Pour les bases de données commerciales, il est nécessaire de télécharger ces fichiers manuellement. Celà est lié aux licences.

* `DB2 driver JDBC <https://www-304.ibm.com/support/docview.wss?rs=4020&uid=swg27016878>`_
* `MS Sql Server driver JDBC <http://msdn.microsoft.com/en-us/sqlserver/aa937724>`_
* `Oracle driver JDBC <http://www.oracle.com/technetwork/database/features/jdbc/index-091264.html>`_


Créer et initialiser les tables
```````````````````````````````


Depuis la version 2.6.x, |project_name| dispose d'un **mécanisme de création et migration de la base de données automatique** au démarrage.
Si les tables ne sont pas présentes dans la base de données, le script de création est lancé.

Ensuite, |project_name| vérifie la version de la base de données correspond à la version de l'application
en vérifiant les valeurs dans la table *Settings* du paramètre *version*.

Une autre alternative est de lancer manuellement les scripts SQL: 

* Création : **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/create/**
* Données initiales : **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/data/**
* Migration :  **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/migrate/**

Exemple d'exécution pour DB2::

        db2 create db geonet
        db2 connect to geonet user db2inst1 using mypassword
        db2 -tf GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/create/create-db-db2.sql > res1.txt
        db2 -tf GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/data/data-db-default.sql > res2.txt
        db2 connect reset

Après exécution, vérifier **res1.txt** et **res2.txt**.


.. note::

    Problèmes connus avec DB2. Il est possible d'obtenir l'erreur suivante au premier lancement.

        DB2 SQL error: SQLCODE: -805, SQLSTATE: 51002, SQLERRMC: NULLID.SYSLH203

    Solution 1 : installer la base manuellement.
    Solution 2 : supprimer la base, la recréer puis localiser le fichier db2cli.lst dans le répertoire d'installation de DB2, puis exécuter :

        db2 bind @db2cli.lst CLIPKG 30




Personnaliser l'interface
=========================

Service de traduction Google
----------------------------

Dans le fichier config-gui.xml modifier la section::

            <!-- 
                Google translation service (http://code.google.com/apis/language/translate/overview.html):
                Set this parameter to "1" to activate google translation service.
                Google AJAX API Terms of Use http://code.google.com/apis/ajaxlanguage/terms.html
                
                WARNING: "The Google Translate API has been officially deprecated as of May 26, 2011...
                the number of requests you may make per day will be limited and 
                the API will be shut off completely on December 1, 2011".
              -->
             <editor-google-translate>1</editor-google-translate>


.. _how_to_config_edit_mode:

Configurer les vues en mode édition
-----------------------------------

Dans le fichier config-gui.xml, il est possible de définir les modes disponibles en édition::

  <metadata-tab>
    <simple flat="true"  default="true"/>
    <advanced/><!-- This view should not be removed as this is the only view to be able to edit all elements defined in a schema. -->
    <iso/>
    <fra/>
    <!-- This view display all INSPIRE recommended elements
    in a view : 
    * In flat mode, define which non existing children of the exception must be displayed (using ancestorException)
    * or which non existing element must be displayed (using exception)
    -->
    <inspire flat="true">
       <ancestorException for="EX_TemporalExtent,CI_Date,spatialResolution"/>
       <exception for="result,resourceConstraints,pointOfContact,hierarchyLevel,couplingType,operatesOn,distributionInfo,onLine,identifier,language,characterSet,topicCategory,serviceType,descriptiveKeywords,extent,temporalElement,geographicElement,lineage"/>
    </inspire> 
    <xml/>
  </metadata-tab>


L'attribut **flat** permet de n'afficher que les éléments existants.
Mettre les éléments non souhaités en commentaire.



Optimiser la configuration pour les catalogues volumineux
=========================================================

Quelques conseils à prendre en compte pour les catalogues volumineux à partir de 20 000 fiches :

#. **Disque** : Le catalogue utilise une base de données pour le stockage mais utilise 
   un moteur de recherches reposant sur Lucene. Lucene est très rapide et le restera 
   y compris pour des catalogues volumineux à condition de lui fournir des disques rapides 
   (eg. SSD – utiliser la variable de configuration de l'index pour placer uniquement l'index 
   sur le disque SSD, si vous ne pouvez placer toute l'application dessus), 
   de la mémoire (16Gb+) et des CPU dans un environnement 64bits. 
   Par exemple, les phases de moissonnage nécessitent de nombreux accès disques 
   lors de la mise à jour de l'index. Privilégier des disques rapides dans ce cas là.

#. **Base de données** : Privilégier l'utilisation du couple PostgreSQL + PostGIS car 
   l'index spatial au format ESRI Shapefile sera moins performant dans les phases d'indexation
   et de recherche lorsque le nombre de fiches sera important.

#. **CPU** : Depuis septembre 2011, les actions d'indexations et opérations massives 
   peuvent être réparties sur plusieurs processus. Ceci est configurable à partir de
   la configuration du système. Une bonne pratique est de fixer la valeur 
   fonction du nombre de processeurs ou core de la machine.

#. **Base de données / taille du pool** : Ajuster la valeur de la taille du pool fonction
   du nombre de moissonnages pouvant être lancés en parallèle, du nombre d'actions massives
   et du nombre d'utilisateurs simultannés. Plus la taille du pool est importante, moins
   le temps d'attente pour récupérer une connexion libre sera long (le risque de timeout sera également moindre).

#. **Nombre de fichiers ouverts** : La plupart des systèmes d'exploitation limite le nombre 
   de fichiers ouverts. Lors de forte charge de mise à jour de l'index, le nombre
   de fichiers ouverts peut être source d'erreur. Modifier la configuration du
   système en conséquence  (eg. ulimit -n 4096).

#. **Mémoire** : La consigne ici est d'allouer le maximum de mémoire fonction de la machine

#. **Créer un catalogue de plus d'1 million d'enregistrements** : Le catalogue crée
   dans le répertoire DATA un répertoire par fiche contenant lui-même 2 
   répertoires public et private. Il est possible que le nombre maximum d'inode soit
   alors atteint, le système retournant alors des erreurs du type 'out of space' bien que
   le système dispose de place disponible. Le nombre d'inode ne peut être modifié dynamiquement 
   après création du système de fichier. Il est donc important de penser à fixer
   la valeur lors de la création du système de fichier. Une valeur de 5 fois 
   (voire 10 fois) le nombre de fiches prévues devrait permettre de
   stocker le répertoire DATA sur ce système de fichier.
   
   
.. _geonetwork_data_dir:


Répertoire de données du catalogue
==================================

Lors du déploiement du catalogue sur un serveur en particulier, il est alors nécessaire de modifier la configuration par défaut. Une façon de faire 
est de modifier les fichiers de configuration à l'intérieur de l'application web. Dans ce cas, il vous faudra une application différente pour chaque
déploiement ou bien faire à chaque mise à jour les modifications de cette configuration.

|project_name| dispose de 2 méthodes pour simplifier la configuration :

 #. Le répertoire de données du catalogue
 #. La surcharge de configuration (Cf. :ref:`adv_configuration_overriddes`)


Le répertoire de données du catalogue (ou GeoNetwork data directory) est un répertoire sur le système de fichiers dans lequel
|project_name| stocke les fichiers de configuration. Cette configuration définie par exemple:
Quels thesaurus sont utilisés ? Quels standards de métadonnées sont chargés ? 
Le répertoire de données contient également différents fichiers nécessaire au bon fonctionnement de l'application (eg. l'index Lucene, l'index spatial, les logos).


Il est recommandé de définir un répertoire de données lors du passage en production afin de simplifier les mises à jour.

Créer le répertoire de données
------------------------------

Le répertoire de données doit être créé avant le lancement du catalogue. Il doit être possible pour l'utlisateur lançant l'application d'y lire et d'y écrire.
Si le répertoire est vide, le catalogue initialisera sa structure au démarrage. Le plus simple pour créer un nouveau répertoire de données et de copier
le répertoire d'une installation par défaut.

Définir le répertoire de données
--------------------------------

Le répertoire de données peut être configuré de 3 façons différentes:

 - variable d'environnement Java
 - paramètre de context du Servlet
 - variable d'environnement du système


Pour les variables d'environnement Java ou les paramètres de context du Servlet, il faut utiliser :

 - <webappName>.dir sinon :
 - geonetwork.dir


Pour les variables d'environnement du système, il faut utiliser :

 - <webappName>_dir sinon
 - geonetwork_dir


Variables d'environnement Java
------------------------------

En fonction du container Java, il est possible de définir les variables d'environnement Java. Pour Tomcat, la configuration est ::

  CATALINA_OPTS="-Dgeonetwork.dir=/var/lib/geonetwork_data"


Lancement de l'application en mode lecture-seule
------------------------------------------------

Afin de lancer le catalogue avec le répertoire de l'application en mode lecture seule, l'utilisateur doit configurer 2 variables :

 - <webappName>.dir ou geonetwork.dir pour le répertoire des données.
 - (optionel) la surcharge de configuration si les fichiers de configurations doivent être modifiés (Cf. :ref:`adv_configuration_overriddes`).
 
 
Pour Tomcat, la configuration pourrait être la suivante ::

  CATALINA_OPTS="-Dgeonetwork.dir=/var/lib/geonetwork_data -Dgeonetwork.jeeves.configuration.overrides.file=/var/lib/geonetwork_data/config/my-config.xml"


Structure du répertoire des données
-----------------------------------

La structure du répertoire des données est la suivante ::


 data_directory/
  |--data
  |   |--metadata_data: Les données associées aux fiches
  |   |--resources:
  |   |     |--htmlcache
  |   |     |--images
  |   |     |   |--harvesting
  |   |     |   |--logo
  |   |     |   |--statTmp
  |   |
  |   |--removed: Le répertoire contenant les fiches supprimées
  |   |--svn_repository: Le dépôt subversion pour la gestion des versions
  |
  |--config: Extra configuration (eg. overrides)
  |   |--schemaplugin-uri-catalog.xml
  |   |--JZKitConfig.xml
  |   |--codelist: Les thésaurus au format SKOS
  |   |--schema_plugins: Le répertoire utilisé pour stocker les standards enfichables
  |
  |--index: Les indexes
  |   |--nonspatial: L'index Lucene
  |   |--spatialindex.*: ESRI Shapefile pour l'index spatial (si PostGIS n'est pas utilisé)
  
  

Configuration avancée
---------------------

Tous les sous-répertoires peuvent être configurés séparément. Par exemple, pour positionner l'index dans un répertoire en particulier, il est possible d'utiliser :

 - <webappName>.lucene.dir sinon
 - geonetwork.lucene.dir


Exemple:

 - Ajouter les variables d'environnement Java au script de lancement start-geonetwork.sh ::
    
    java -Xms48m -Xmx512m -Xss2M -XX:MaxPermSize=128m -Dgeonetwork.dir=/app/geonetwork_data_dir -Dgeonetwork.lucene.dir=/ssd/geonetwork_lucene_dir

 - Ajouter les variables systèmes au script de lancement start-geonetwork.sh ::

    # Set custom data directory location using system property
    export geonetwork_dir=/app/geonetwork_data_dir
    export geonetwork_lucene_dir=/ssd/geonetwork_lucene_dir


Information système
-------------------

Toute la configuration peut être consultée depuis l'administration > information système.

    .. figure:: geonetwork-data-dirs.png



Autres variables de configuration
---------------------------------

Dans |project_name|, d'autres variables de configuration sont disponibles:

 * <webappname>.jeeves.configuration.overrides.file - Cf. :ref:`adv_configuration_overriddes`
 * jeeves.configuration.overrides.file - Cf. :ref:`adv_configuration_overriddes`
 * mime-mappings -  mime mappings used by jeeves for generating the response content type
 * http.proxyHost - The internal geonetwork Http proxy uses this for configuring how it can access the external network (Note for harvesters there is also a setting in the Settings page of the administration page)
 * http.proxyPort - The internal geonetwork Http proxy uses this for configuring how it can access the external network (Note for harvesters there is also a setting in the Settings page of the administration page)
 * geonetwork.sequential.execution - (true,false) Force indexing to occur in current thread rather than being queued in the ThreadPool.  Good for debugging issues.


Dans le cas où plusieurs catalogues sont installés dans le même container, il est recommandé de substituer 
dans les noms des propriétés <webappname> par le nom de la webapp afin d'éviter les conflits entre catalogue.



.. _adv_configuration_overriddes:

Surcharge de configuration
==========================

Configuration override files allow nearly complete access to all the configuration allowing nearly any configuration parameter to be overridden 
for a particular deployment target.  The concept behind configuration overrides is to have the basic configuration set in the geonetwork webapplication,
the application is deployed and a particular set of override files are used for the deployment target.  The override files only have the settings that need
to be different for the deployment target, alleviating the need to deploy and edit the configuration files or have a different web application per deployment target.

Configuration override files are also useful for forked Geonetwork applications that regularily merge the changes from the true Geonetwork code base.

A common scenario is to have test and production instances with different configurations. In both configurations 90% of the configuration is the same 
but certain parts need to be updated.

An override file to be specified as a system property or as a servlet init parameter: jeeves.configuration.overrides.file.

The order of resolution is:
 * System property with key: {servlet.getServletContext().getServletContextName()}.jeeves.configuration.overrides.file
 * Servlet init parameter with key: jeeves.configuration.overrides.file
 * System property with key: jeeves.configuration.overrides.file
 * Servlet context init parameters with key: jeeves.configuration.overrides.file
 
The property should be a path or a URL.  The method used to find a overrides file is as follows:
 #. It is attempted to be used as a URL.  if an exception occurs the next option is tried
 #. It is assumed to be a path and uses the servlet context to look up the resources.  If it can not be found the next option is tried
 #. It is assumed to be a file.  If the file is not found then an exception is thrown

An example of a overrides file is as follows::
   
   <overrides>
       <!-- import values.  The imported values are put at top of sections -->
       <import file="./imported-config-overrides.xml" />
        <!-- properties allow some properties to be defined that will be substituted -->
        <!-- into text or attributes where ${property} is the substitution pattern -->
        <!-- The properties can reference other properties -->
        <properties>
            <enabled>true</enabled>
            <dir>xml</dir>
            <aparam>overridden</aparam>
        </properties>
        <!-- A regular expression for matching the file affected. -->
        <file name=".*WEB-INF/config\.xml">
            <!-- This example will update the file attribute of the xml element with the name attribute 'countries' -->
            <replaceAtt xpath="default/gui/xml[@name = 'countries']" attName="file" value="${dir}/europeanCountries.xml"/>
            <!-- if there is no value then the attribute is removed -->
            <replaceAtt xpath="default/gui" attName="removeAtt"/>
            <!-- If the attribute does not exist it is added -->
            <replaceAtt xpath="default/gui" attName="newAtt" value="newValue"/>

            <!-- This example will replace all the xml in resources with the contained xml -->
            <replaceXML xpath="resources">
              <resource enabled="${enabled}">
                <name>main-db</name>
                <provider>jeeves.resources.dbms.DbmsPool</provider>
                 <config>
                     <user>admin</user>
                     <password>admin</password>
                     <driver>oracle.jdbc.driver.OracleDriver</driver>
                     <!-- ${host} will be updated to be local host -->
                     <url>jdbc:oracle:thin:@${host}:1521:fs</url>
                     <poolSize>10</poolSize>
                 </config>
              </resource>
            </replaceXML>
            <!-- This example simple replaces the text of an element -->
            <replaceText xpath="default/language">${lang}</replaceText>
            <!-- This examples shows how only the text is replaced not the nodes -->
            <replaceText xpath="default/gui">ExtraText</replaceText>
            <!-- append xml as a child to a section (If xpath == "" then that indicates the root of the document),
                 this case adds nodes to the root document -->
            <addXML xpath=""><newNode/></addXML>
            <!-- append xml as a child to a section, this case adds nodes to the root document -->
            <addXML xpath="default/gui"><newNode2/></addXML>
            <!-- remove a single node -->
            <removeXML xpath="default/gui/xml[@name = countries2]"/>
            <!-- The logging files can also be overridden, although not as easily as other files.  
                 The files are assumed to be property files and all the properties are loaded in order.  
                 The later properties overriding the previously defined parameters. Since the normal
                 log file is not automatically located, the base must be also defined.  It can be the once
                 shipped with geonetwork or another. -->
            <logging>
                <logFile>/WEB-INF/log4j.cfg</logFile>
                <logFile>/WEB-INF/log4j-jeichar.cfg</logFile>
            </logging>
        </file>
        <file name=".*WEB-INF/config2\.xml">
            <replaceText xpath="default/language">de</replaceText>
        </file>
        <!-- a normal file tag is for updating XML configuration files -->
        <!-- textFile tags are for updating normal text files like sql files -->
        <textFile name="test-sql.sql">
            <!-- each line in the text file is matched against the linePattern attribute and the new value is used for substitution -->
            <update linePattern="(.*) Relations">$1 NewRelations</update>
            <update linePattern="(.*)relatedId(.*)">$1${aparam}$2</update>
        </textFile>
    </overrides>

