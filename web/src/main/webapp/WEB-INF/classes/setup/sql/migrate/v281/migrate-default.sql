UPDATE dbo.Settings SET value='2.8.1' WHERE name='version';
UPDATE dbo.Settings SET value='SNAPSHOT' WHERE name='subVersion';

CREATE TABLE dbo.MetadataGroupRelations
  (
    metadatauuid         varchar(250)   not null,
    groupname         varchar(32)    not null,
    primary key(metadatauuid)
  );
CREATE TABLE dbo.CatalogueMetadataRelations
  (
    catalogueuuid         varchar(250)   not null,
    metadatauuid         varchar(250)    not null,
    primary key(catalogueuuid, metadatauuid)
  );