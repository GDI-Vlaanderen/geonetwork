.. _metadata:

Metadata in Spatial Data Management
===================================

What is Metadata?
-----------------

Metadata, commonly defined as “data about data” or "information about data", is a structured set of
information which describes data (including both digital and non-digital datasets)
stored in administrative systems. Metadata may provide a short summary about the
content, purpose, quality, location of the data as well as information related to
its creation.

What are Metadata Standards?
----------------------------

Metadata standards provide data producers with the format and content for properly
describing their data, allowing users to evaluate the usefulness of the data in
addressing their specific needs.

The standards provide a documented, common set of terms and definitions
that are presented in a structured format.

Why do we need Standardised Metadata?
-------------------------------------

Standardised metadata support users in effectively and efficiently accessing data
by using a common set of terminology and metadata elements that allow for a quick
means of data discovery and retrieval from metadata clearinghouses. The metadata
based on standards ensure information consistency and quality and avoid that
important parts of data knowledge are lost.

Geographic Information Metadata Standard
----------------------------------------

Geographic data, which can be defined as any data with a geographic component, is
often produced by one individual or organisation, and may address the needs of
various users, including information system analysts, programme planners, developers
of geographic information or policy makers. Proper standard documentation on
geographic data enable different users to better evaluate the appropriateness of
data to be used for data production, storage, update.

The metadata standards supported by GeoNetwork opensource are the **ISO 19115:2003** -
approved by the international community in April 2003 as a tool to define metadata
in the field of geographic information - and the **FGDC** - the metadata standard 
adopted in the United States by the Federal Geographic Data Committee. 
In addition, GeoNetwork opensource supports also the international
standard **Dublin Core** for the description of general documents.

This ISO Standard precisely defines how geographic information and related
services should be described, providing mandatory and conditional metadata sections,
metadata entities and metadata elements. This standard applies to data series,
independent datasets, individual geographic features and feature properties. Despite
ISO 19115:2003 was designed for digital data, its principles can be extended to many
other forms of geographic data such as maps, charts, and textual documents as well
as non-geographic data.

The underlying format of an ISO19115:2003 compliant metadata is XML. GeoNetwork
uses the *ISO Technical Specification 19139 Geographic information - Metadata -
XML schema implementation* for the encoding of this XML.

Metadata profiles
-----------------

GeoNetwork supports multiple metadata profiles. Profiles can take the form of
*Templates* that you can create using the metadata editor.
Using the Advanced view of the editor, virtually all of the metadata elements
are accessible to the user.

Support for extensions to a metadata standard can also be achieved relatively
quick by an experienced XML/XSL software engineer.

Transition between metadata standards
-------------------------------------

With the ISO19115:2003 Metadata standard for Geographic Information now
being the preferred common standard, many have a need to migrate legacy metadata
into the new standard.

GeoNetwork provides import (and export) functionality and has a number of
transformers in place. It is an easy process for a system administrator to
install custom transformers based on XSLT.
