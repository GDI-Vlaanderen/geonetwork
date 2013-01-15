.. _processing:

Processing
==========

GeoNetwork provides some batch processing capability. Process are defined using XSL in the schema process folder.
Process could be used in:

 * Harvesting for filtering harvested records from another GeoNetwork node (See :ref:`harvesting_gn`)
 * Editor for the suggestion mechanism
 * Advanced administration to manually calling xml.batch.processing service

Process available
-----------------

Anonymizer
~~~~~~~~~~

 * schema: ISO19139
 * usage: Harvester

Anonymiser is an XSL transformation provided for ISO19139 record in GeoNetwork which removes
all resource's contact except point of contact. It also have some custom options to replace email,
remove keywords and remove internal online resources. For this, 3 optional parameters are available:
 
 * protocol: Protocol name for which online resource must be removed
 
 * email: Generic email to use for all email in same domain (ie. after @domain.org).
 
 * thesaurus: Portion of thesaurus name for which keyword should be removed
 
It could be used in the GeoNetwork harvesting XSL filter configuration using::

  anonymizer?protocol=DB:&email=gis-service@myorganisation.org&thesaurus=MYINTERNALTHESAURUS


Scale denominator formatter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

Format scale which contains " ", "/" or ":" characters.

Add extent form geographic keywords
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

Compute extent based on keyword of type place using installed thesaurus.

WMS synchronizer
~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

If WMS server defined in distribution section, suggest to add extent, CRS and graphic overview based on WMS.


Add INSPIRE conformity
~~~~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

If INSPIRE themes found, suggest to add an INSPIRE conformity section.


Add INSPIRE data quality report
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

Suggest the creation of a default topological consistency report
when INSPIRE theme is set to Hydrography, Transport Networks or Utility and governmental services

Keywords comma exploder
~~~~~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

Suggest to explode keywords which contains comma (which is better for indexing and searching).

Keywords mapper
~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Batch process
 
Process records and map keyword define in a mapping table (to be defined manually in the process).


Linked data checker
~~~~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Suggestion

Check URL status and suggest to remove the link on error.


Thumbnail linker
~~~~~~~~~~~~~~~~

 * schema: ISO19139
 * usage: Batch process

This batch process updates in batch all the metadata records to set a thumbnail.

Process parameters:

 * prefix: thumbnail URL prefix (mandatory)
 
 * thumbnail_name: Name of the element to use in the metadata for the thumbnail file name (without extension). This element should be unique in a record. Default is gmd:fileIdentifier (optional).
 
 * thumbnail_desc: Thumbnail description (optional).

 * thumbnail_type: Thumbnail type (optional).
 
 * suffix: Thumbnail file extension. Default is .png (optional).


Inserted fragment is::

    <gmd:graphicOverview>
        <gmd:MD_BrowseGraphic>
          <gmd:fileName>
            <gco:CharacterString>$prefix + $thumbnail_name + $suffix</gco:CharacterString>
          </gmd:fileName>
          <gmd:fileDescription>
            <gco:CharacterString>$thumbnail_desc</gco:CharacterString>
          </gmd:fileDescription>
          <gmd:fileType>
            <gco:CharacterString>$thumbnail_type</gco:CharacterString>
          </gmd:fileType>
        </gmd:MD_BrowseGraphic>
    </gmd:graphicOverview>

