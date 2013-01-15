.. _Contacts:
.. include:: ../../substitutions.txt

Annuaires de contacts
#####################

Introduction
------------

L'application permet de créer des annuaires de contacts partagés. Les utilisateurs peuvent ensuite dans l'interface d'édition ajouter les informations 
associés à ces contacts (nom de l'organisme, adresse, email, ...) à leurs métadonnées.

Cette fonctionnalité permet de ne pas saisir plusieurs fois les mêmes informations dans des champs de métadonnées particuliers (responsable sur la 
ressource, sur la métadonnée, distributeur, ...).


Depuis la version 2.7.1, il est possible de créer différents types d'annuaires, correspondant à des classes particulières (CI_ResponsibleParty 
pour les contacts, chargé par défaut dans l'application). Ces annuaires sont stockés en base de données en tant que métadonnées à part entière, ce 
qui permet de gérer des priviléges sur celles-ci.

Créer un annuaire
-----------------

L'interface est disponible dans Administration puis Gestion des annuaires.

.. figure:: manage_contacts.png

Cliquer sur Ajouter puis copier-coller un fragment XML dans la zone de texte. Sélectionner un groupe auquel rattacher cet annuaire puis cliquer sur Ajouter.

.. figure:: add_directory.png

Modifier un contact
-------------------

Sélectionner un annuaire dans la liste déroulante. Cette étape n'est pas nécessaire si un seul annuaire existe, ou si l'on souhaite rechercher dans 
l'ensemble des annuaires.

Sélectionner un contact dans le tableau de résultats. Les informations associées s'affichent dans la partie droite. L'interface d'édition des contacts 
est similaire à celle des fiches de métadonnées des jeux de données avec les éléments permettant de changer la vue en cours, de sauver, etc.

A noter qu'il n'est pas nécessaire de renseigner le rôle du contact car celui-ci devra être précisé au moment d'ajouter le contact dans l'édition d'une 
fiche de métadonnées.

.. figure:: edit_contact.png

Ajouter un contact
------------------

Pour ajouter un nouveau contact dans un annuaire, sélectionner un contact existant (voir ci-dessus), puis cliquer sur Dupliquer.

Il est également possible de supprimer un contact ou modifier les privilèges sur le contact sélectionné.