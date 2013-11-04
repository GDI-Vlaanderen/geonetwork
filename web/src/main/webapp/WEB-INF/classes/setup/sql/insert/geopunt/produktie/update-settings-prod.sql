UPDATE dbo.Settings SET value='CHANGEME' WHERE name='siteId';
UPDATE dbo.Settings SET value='metadata.geopunt.be' WHERE name='host';
UPDATE dbo.Settings SET value='"failover:(tcp://aocsrv129:61616,tcp://aocsrv128:61616)?randomize=false"' WHERE name='jmsurl';