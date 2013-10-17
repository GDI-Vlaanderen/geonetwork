ALTER TABLE dbo.metadatastatus DROP CONSTRAINT metadatastatus_statusid_fkey;

DELETE FROM dbo.statusvaluesdes;
DELETE FROM dbo.StatusValues;

INSERT INTO dbo.StatusValues VALUES  ('0','unknown','y');
INSERT INTO dbo.StatusValues VALUES  ('6','justcreated','y');
INSERT INTO dbo.StatusValues VALUES  ('1','draft','y');
INSERT INTO dbo.StatusValues VALUES  ('4','submitted','y');
INSERT INTO dbo.StatusValues VALUES  ('2','approved','y');
INSERT INTO dbo.StatusValues VALUES  ('5','rejected','y');
INSERT INTO dbo.StatusValues VALUES  ('3','retired','y');

insert into dbo.statusvaluesdes VALUES ('0','dut','Onbekend');
insert into dbo.statusvaluesdes VALUES ('1','dut','Ontwerp');
insert into dbo.statusvaluesdes VALUES ('2','dut','Intern goedgekeurd en gepubliceerd');
insert into dbo.statusvaluesdes VALUES ('3','dut','Gearchiveerd');
insert into dbo.statusvaluesdes VALUES ('4','dut','Intern ingediend');
insert into dbo.statusvaluesdes VALUES ('5','dut','Afgekeurd door Hoofdeditor');
insert into dbo.statusvaluesdes VALUES ('6','dut','Pas gecreëerd');

ALTER TABLE dbo.metadatastatus
  ADD CONSTRAINT metadatastatus_statusid_fkey FOREIGN KEY (statusid)
      REFERENCES dbo.statusvalues (id);
