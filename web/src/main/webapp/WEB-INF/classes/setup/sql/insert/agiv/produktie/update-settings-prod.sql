--UPDATE dbo.Settings SET value='CHANGEME' WHERE name='siteId';
UPDATE dbo.Settings SET value='metadata.agiv.be' WHERE name='host';
UPDATE dbo.Settings SET value='"failover:(tcp://aocsrv119:61616,tcp://aocsrv118:61616)?randomize=false"' WHERE name='jmsurl';