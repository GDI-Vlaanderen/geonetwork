ALTER TABLE dbo.metadatastatus DROP CONSTRAINT metadatastatus_statusid_fkey;
ALTER TABLE dbo.StatusValues DROP CONSTRAINT statusvalues_pk;
DELETE FROM dbo.statusvaluesdes;
DELETE FROM dbo.StatusValues;

INSERT INTO dbo.StatusValues VALUES  ('0','unknown','y');
INSERT INTO dbo.StatusValues VALUES  ('6','justcreated','y');
INSERT INTO dbo.StatusValues VALUES  ('1','draft','y');
INSERT INTO dbo.StatusValues VALUES  ('4','submitted','y');
INSERT INTO dbo.StatusValues VALUES  ('2','approved','y');
INSERT INTO dbo.StatusValues VALUES  ('5','rejected','y');
INSERT INTO dbo.StatusValues VALUES  ('3','retired','y');
--INSERT INTO dbo.StatusValues VALUES  ('12','removed','y');

INSERT INTO dbo.statusvaluesdes VALUES ('0','dut','Onbekend');
INSERT INTO dbo.statusvaluesdes VALUES ('1','dut','Ontwerp');
INSERT INTO dbo.statusvaluesdes VALUES ('2','dut','Intern goedgekeurd en gepubliceerd');
INSERT INTO dbo.statusvaluesdes VALUES ('3','dut','Gedepubliceerd');
INSERT INTO dbo.statusvaluesdes VALUES ('4','dut','Intern ingediend');
INSERT INTO dbo.statusvaluesdes VALUES ('5','dut','Afgekeurd door Hoofdeditor');
INSERT INTO dbo.statusvaluesdes VALUES ('6','dut','Pas gecreëerd');
--INSERT INTO dbo.statusvaluesdes VALUES ('12','dut','Verwijderd');

ALTER TABLE dbo.StatusValues ADD CONSTRAINT statusvalues_pk PRIMARY KEY NONCLUSTERED(id);
ALTER TABLE dbo.metadatastatus ADD CONSTRAINT metadatastatus_statusid_fkey FOREIGN KEY (statusid) REFERENCES dbo.statusvalues (id);
