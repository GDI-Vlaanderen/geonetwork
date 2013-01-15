.. _configuration:
.. include:: ../../substitutions.txt

.. toctree::
   :maxdepth: 2

Paramètres du catalogue
=======================

.. _configuration_system:

Configuration du système
------------------------

La majorité des options de configuration du catalogue sont accessibles depuis la page
web d'administration. Il est important de bien configurer ces options, car un catalogue
mal configuré pourrait avoir des problèmes pour permettre le téléchargement des fichiers, 
des imagettes, ou lors du moissonnage par d'autres catalogues.

Pour configurer le catalogue, l'utilisateur doit être connecté en tant qu'administrateur.

Aller à la page d'administration, puis sélectionner configuration du système.


.. important:: Lors d'une installation par défaut du catalogue, l'utilisateur admin est identifié
    par le mot de passe admin. Il est important de changer ces valeurs par défaut.


.. figure:: web-config-where.png

    Lien vers la page de configuration du système


.. FIXME too large ::figure:: web-config-options.png

    Les options de configuration

Les boutons au bas de la page permettent de retourner à la page administration, de sauver les changements
ou recharger la configuration.



Les paramètres publics hôte et port
```````````````````````````````````

Ces 2 paramètres sont utilisés dans les cas suivants :

#. Lors d'une session d'édition, lors de l'ajout de données associées à une métadonnée. 
    ces paramètres sont utilisés pour construire l'URL pour le téléchagement dans la métadonnée

#. Lors de requête CSW. Le document GetCapabilities retourne des liens HTTP vers le service CSW. 


Paramètres généraux du site
```````````````````````````

- Site

 - Nom : Le nom du catalogue est utilisé dans le critère de recherche **catalogue**, ou dans le moissonnage

 - Organisme : Le nom de l'organisation à laquelle appartient le catalogue

- Serveur reseigne sur l'adresse publique du catalogue

 - **Hôte** L'URL publique ou l'adresse IP du catalogue. 
 
 - **Port** Le port est en général 80 (ie. http) ou plus rarement 8080.

- Intranet est utilisé pour distinguer les utilisateurs du catalogue sur le réseau Intranet de l'organisation

 - **Network** adresse IP du réseau

 - **Masque de sous réseau**


Paramètre de recherches et indexation
`````````````````````````````````````
- Résultat de recherche

 - Nombre maximum d'items sélectionnés permet de limiter la sélection d'un trop grand nombre d'enregistrement à la fois. 
   Ce paramètre évite des problèmes de performance sur les opérations massives.
    
- Optimisation de l'index : Activé par défaut. Ce processus permet de régulièrement "ranger" l'index Lucene.
  L'opération est rapide pour des catalogues peu volumineux.

Paramètre de configuration du services Z39.50
`````````````````````````````````````````````

Le catalogue supporte le protocol serveur Z39.50 qui est un protocole d'interrogation de métadonnées.

- **Activé** : Cette option permet d'activer ou pas au démarrage le protocole. Le redémarrage est nécessaire 
  pour la prise en compte de ce paramètre. Activé par défaut.

- **port** : Port d'écoute pour les requêtes Z39.50. Par défaut ce port est le 2100. 
  Il est possible de changer ce port, si plusieurs catalogues sont déployés sur le même serveur. 
  Ce port doit être ouvert si un pare-feu se trouve devant le catalogue.


Paramètre de configuration du services OAI-PMH
``````````````````````````````````````````````

Le catalogue support le protocol serveur OAI-PMH.

Les paramètres suivants sont disponibles :

- Datesearch : Utilisé l'étendue temporelle ou la date de modification sur les recherches temporelles

- Resumption token timeout

- Taille du cache


XLink
`````

Activé ou désactivé la résolution des XLinks présents dans les métadonnées.


Statistique sur les recherches
``````````````````````````````

Activé ou désactivé la génération de statistique sur les recherches (cf :ref:`stat_config`).


Service de téléchargement
`````````````````````````

Les fichiers associés aux métadonnées peuvent être accessible au téléchargement selon 3 modes :

- Utiliser le service de téléchargement |project_name| (resources.get)

- Utiliser le service analysant les contraintes d'accès |project_name| (file.disclaimer)

- Utiliser les liens de la section distribution - sans changement



Hyperliens cliquables
`````````````````````

Activé ou désactivé la recherche de liens dans le contenu des métadonnées. Ces liens sont transformés
en lien <a href=".."> pour les url http et les adresses emails. Cette option affecte légérement les performances d'affichage.


Evaluation locale
`````````````````

Activé ou désactivé l'évaluation locale des métadonnées. Lorsqu'un utilisateur note une métadonnée, la note est transmie 
au catalogue source lorsque cette métadonnée est moissonnée selon le protocol |project_name|.


Correction automatique
``````````````````````

Activé ou désactivé la correction automatique. Lors de la sauvegarde d'une métadonnée des informations sont mises à jour
automatiquement par le catalogue (eg. ajout des attributs gco:isoType obligatoire, gco:nilReason pour les champs textes vide
définition des liens pour le téléchargement).
Il est fortement recommandé de conserver cette option activée sauf si vous savez ce que vous faites !




INSPIRE
```````
Activé ou désactivé les options INSPIRE :

- CSW GetCapabilities INSPIRE

- Indexation des thèmes INSPIRE (nécessite de relancer l'indexation)

- Formulaire de recherche INSPIRE (selon l'interface)



Moissonnage
```````````

Permettre ou non l'édition de fiche moissonnée (sachant que fonction du protocol de moissonnage, la fiche pourra
être écrasé si le moissonnage est relancé).

Configuration du proxy
``````````````````````


Dans certaines situations, le catalogue doit être capable d'accèder à des sites distants. Il est 
alors nécessaire pour lui de passer par le proxy de l'organisation.

.. figure:: web-config-options-proxy.png



- *Hôte*: Adresse IP ou nom du proxy

- *Port*: Le port du proxy

- *Utilisateur* (optionel)

- *Mot de passe* (optionel)



Configuration du proxy pour le proxy du catalogue
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

L'interface cliente javascript du catalogue à parfois besoin de réaliser des appels vers d'autre
site (eg. récupération d'un GetCapabilities par le module cartographique). Pour cela, 
elle a besoin d'un proxy au niveau du serveur. Si vous utilisez le proxy par défaut
du catalogue et que ce proxy doit passer par un proxy côté serveur pour accèder à Internet, il est alors nécessaire de
définir les variables d'environnement http.proxyHost et http.proxyPort [#fproxy]_ au lancement de l'application.
Il est possible d'ajouter ces paramètres au lancement du container Java avec les paramètres suivants ::

  -Dhttp.proxyHost=my.proxy.org -Dhttp.proxyPort=8080


.. _configuration_system_email:

Alerte et notification
``````````````````````

Le catalogue peut notifier par email lorsqu'une métadonnée est téléchargée ou lorsqu'un utilisateur
rempli le formulaire de contact. Dans ce cas, il est nécessaire de configurer le serveur de mail

.. figure:: web-config-options-mailserver.png

    Configuration du serveur de mail

- **Email**: adresse utilisée pour l'envoi des mails (ie. From:)

- **Serveur SMTP**: IP du serveur de mail

- **Port SMTP**: Port du serveur de mail (en général 25).

Métadonnée supprimée
````````````````````

Permet de définir le répertoire à utiliser pour la sauvegarde lors de la suppression d'une métadonnée.
Ce répertoire permet pour les administrateurs du système de récupérer des métadonnées supprimées par erreur.


Configuration de l'authentication
`````````````````````````````````

Cette section permet de définir le mode d'authentification pour le catalogue.

.. figure:: web-config-options-authentication.png

    Options de configuration du mode d'authentification
    

Par défaut, les utilisateus sont identifiés par la base de données du catalogue. 
Dans ce mode là, il est possible d'activer l'option d'enregistrement libre des internautes (alors membre du groupe invité).

LDAP (lightweight directory access protocol) est un autre mode d'authentification supporté par le catalogue.  ).

Shibboleth est un autre mode d'authentification utilisable en complément des 2 autres modes. Tous les utilisateurs
de la fédération peuvent alors s'authentifier auprès du catalogue.


Configuration de l'authentification LDAP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The section defines how to connect to an LDAP authentication system.

.. figure:: web-config-options-ldap.png

    *The LDAP configuration options*

Typically all users must have their details in the LDAP directory to login to |project_name|. 
However if a user is added to the |project_name| database with the Administrator profile then they will be able to login without 
their details being present in the LDAP directory.

Configuration de l'authentification Shibboleth
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When using either the |project_name| database or LDAP for authentication, you can also configure 
shibboleth to allow authentication against access federations.

.. figure:: web-config-options-shibboleth.png

    *The Shibboleth configuration options*

Shibboleth authentication requires interaction with Apache web server. In particular, 
the apache web server must be configured to require Shibboleth authentication to access the path 
entered in the configuration. The apache web server configuration will contain the details of the shibboleth 
server that works out where a user is located (sometimes called a 'where are you from' server).

The remainder of the shibboleth login configuration describes how shibboleth authentication 
attributes are mapped to |project_name| user database fields as once a user is authenticated against shibboleth, 
their details are copied to the local |project_name| database.


.. _csw_configuration:

Configuration CSW
-----------------

Configuration minimale
``````````````````````

When using Open Geospatial Catalogue Service for the Web (OGC-CSW) service,
a client will ask for a description of the
service. This description, provided in the form of a GetCapabilities document, describes
the main service's properties. The administration section allows
configuration of the following CSW properties:

*Enable*: This option allows you to start or stop the CSW
services. If this option is disabled, other catalogues cannot
connect to the node using CSW protocol.

*Contact*: The main contact who is defined in
the GetCapabilities document of the CSW service. This contact is one
user of the catalogue.

*Title*: The title of your CSW service.

*Abstract*: The abstract of your CSW service.

*Fees*

*Access constraints*

The service description also contains the main keywords of the catalogue.
The list of keywords is generated by the catalogue based on metadata
content.

*Inserted metadata is public*: By default, metadata inserted with CSW Transaction operation is not 
public viewable unless a user with proper rights, sets later the metadata permissions to be public 
viewable. If this option is checked all metatada inserted with CSW Transation is public viewable by default.


.. figure:: csw-configuration.png

Configuration avancée
`````````````````````

Une configuration plus fine du CSW est possible via le fichier **WEB-INF/config-csw.xml**. Les options suivantes sont disponibles :

- Nombre de mots clés retournés dans la réponse du GetCapabilities

- Nombre de métadonnées analysées pour le calcul des mots clés les plus fréquents::

        <operation name="GetCapabilities">
            <!-- Defines the number of keywords displayed in capabilities, ordered by frequency -->
            <numberOfKeywords>10</numberOfKeywords>
            <!-- Defines the number of records that will be processed to build the keyword frequency list  -->
            <maxNumberOfRecordsForKeywords>1000</maxNumberOfRecordsForKeywords>
        </operation>

- La section GetRecord indique les correspondances entre les champs définis dans la spécification CSW (ou INSPIRE) et les champs
  de l'index Lucene. Un champ non présent dans cette liste et existant dans l'index est intérrogeable avec le nom de ce champ dans l'index.

.. _system_info:

Information sur le système
--------------------------

La page d'information permet de récupérer les principales caractéristiques du catalogue. Ces informations
peuvent être utils pour la résolution des problèmes.

.. figure:: info.png



.. _logo_config:

Configuration et gestion des logos
----------------------------------

A partir de la page administration il est possible de gérer les logos. Les actions possibles sont :

- ajout de logo dans le catalogue (utilisé pour la définition du logo du catalogue et ceux des points de moissonnage)

- définition du logo du catalogue

- définition de l'icône favorite du catalogue (il est recommandé d'utiliser une image de forme carré pour cela car elle
    sera redimmensionnée au format 16x16 px)
    
    
.. figure:: config-logo.png


.. _stat_config:

Statistique sur les recherches
------------------------------

Une fois activé, il est possible d'accéder à la page de consultation des statistiques.

Cette page présente un certain nombre d'indicateurs produit à partir des logs de recherches.

Par exemple :

- Mots les plus recherchés
- Nombre de recherche (par an/mois/jours, par type)
- Adresse IP des clients
- Popularité des métadonnées


.. figure:: admin-statistical.png


Ces statistiques peuvent être téléchargé au format CSV.


Dans le fichier de configuration WEB-INF/config.xml, des options avancées sont disponibles pour choisir les champs
de recherche à enregistrer, activé ou pas le log des critéres géographiques ... ::

        <!-- search statistics stuff -->
        <!-- true to log into DB WKT of spatial objects involved in a search operation
        CAUTION ! this can lead to HUGE database and CSV export if detailed geo objects are used:
        several Gb for instance...-->
        <param name="statLogSpatialObjects" value="false" />
        <param name="statLogAsynch" value="true" />
        <!-- The list of Lucene term fields to exlucde from log, to avoid storing unecessary information -->
        <param name="statLuceneTermsExclude" value="_op0,_op1,_op2,_op3,_op4,_op5,_op6,_isTemplate,_locale,_owner,_dummy,type" />
    </appHandler>



.. rubric:: Footnotes

.. [#fproxy] http://docs.oracle.com/javase/6/docs/technotes/guides/net/proxies.html
