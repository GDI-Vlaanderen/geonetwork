--UPDATE dbo.Settings SET value='CHANGEME' WHERE name='siteId';
UPDATE dbo.Settings SET value='metadata.beta.agiv.be' WHERE name='host';
UPDATE dbo.Settings SET value='failover:(tcp://aocsrv104:61616,tcp://aocsrv105:61616)?randomize=false' WHERE name='jmsurl';