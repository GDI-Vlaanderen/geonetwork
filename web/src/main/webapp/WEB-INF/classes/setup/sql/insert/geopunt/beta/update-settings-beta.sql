--UPDATE dbo.Settings SET value='CHANGEME' WHERE name='siteId';
UPDATE dbo.Settings SET value='metadata.beta.geopunt.be' WHERE name='host';
UPDATE dbo.Settings SET value='"failover:(tcp://aocsrv135:61616,tcp://aocsrv134:61616)?randomize=false"' WHERE name='jmsurl';