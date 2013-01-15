.. _multilingual:

Multilingual search
=========

Introduction
------------

GeoNetwork supports *multilingual* search. Depending on the configuration, this influences which search results are returned and how they are presented:

- *only in the requested language*: only search results in the requested language are returned

- *requested language on top*: search results in all languages are returned, with results in the requested language sorted to the top

- *ignore requested language*: results in all languages are returned, with no specific sorting for the requested language

Administrator users can change these settings in the System Configuration page:

.. figure:: requested-language-behaviour.png

Requested language
-----------------------

The requested language is determined as follows (in this order):

- request parameter: in the GUI, the user may select a language:

.. figure:: requested-language-in-search-form.png

 For XML searches, the client may add::

    <requestedLanguage>language-code</requestedLanguage>

where language-code is one of the ISO 639-2 (three-character) language codes, see http://www.loc.gov/standards/iso639-2/php/code_list.php.

- if the request parameter is not sent (the user selected "any" language, or it's not in the XML request), the requested language may be automatically detected, if an Administrator user has enabled this in the System Configuration:

.. figure:: enable-auto-detection.png

The auto-detection feature uses Language Detection Library for Java, see https://code.google.com/p/language-detection/. This library tries to detect the language of search terms in parameter 'any'. This may not work very well, depending on the language, if there is only one or very few search terms. This is why this feature is disabled by default. At the time of writing the auto-detection supports these languages:

    - Afrikaans
    - Arabic
    - Bulgarian
    - Bengali
    - Czech
    - Danish
    - German
    - Greek (modern)
    - English
    - Spanish
    - Estonian
    - Persian
    - Finnish
    - French
    - Gujarati
    - Hebrew
    - Hindi
    - Croatian
    - Hungarian
    - Indonesian
    - Italian
    - Japanese
    - Kannada
    - Korean
    - Lithuanian
    - Latvian
    - Macedonian
    - Malayalam
    - Marathi
    - Nepali
    - Dutch
    - Norvegian
    - Punjabi
    - Polish
    - Portuguese
    - Romanian
    - Russian
    - Slovak
    - Slovenian
    - Somali
    - Albanian
    - Swedish
    - Swahili
    - Tamil
    - Telugu
    - Thai
    - Tagalog
    - Turkish
    - Ukrainian
    - Urdu
    - Vietnamese
    - Chinese (traditional)
    - Chinese (simplified)

- if autodetecting the language is disabled (the default), the current language of the user's GUI is used as the requested language

- if there is no GUI, the requested language is hardcoded to be English

Stopwords
------------------------
Stopwords are words that are considered to carry little or no meaning relevant to search. To improve relevance ranking of search results, stopwords are often removed from search terms. In GeoNetwork stopwords are automatically used if a stopwords list for the requested language is available; if not, no stopwords are used. At the time of writing there are stopword lists for:

    - Arabic
    - Bulgarian
    - Bengali
    - Catalan
    - Czech
    - Danish
    - German
    - Greek (modern)
    - English
    - Spanish
    - Persian
    - Finnish
    - French
    - Hindi
    - Hungarian
    - Italian
    - Japanese
    - Korean
    - Marathi
    - Malay
    - Dutch
    - Norvegian
    - Polish
    - Portuguese
    - Romanian
    - Russian
    - Swedish
    - Turkish
    - Chinese

System administrators may add additional languages' stopword lists by placing them in the directory <geonetwork>/web/resources/stopwords. The filenames should be <ISO 639-2 code>.txt. If you do add a stopwords list for another language, please consider contributing it for inclusion in GeoNetwork.

Likewise, to disable stopwords usage for one or more languages, the stopword list files should be removed or renamed.