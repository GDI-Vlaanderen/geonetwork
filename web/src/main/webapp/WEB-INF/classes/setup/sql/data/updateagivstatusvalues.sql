ALTER TABLE dbo.metadatastatus DROP CONSTRAINT metadatastatus_statusid_fkey;

delete from dbo.statusvaluesdes;
DELETE FROM dbo.StatusValues;
INSERT INTO dbo.StatusValues VALUES  ('0','unknown','y');
INSERT INTO dbo.StatusValues VALUES  ('6','justcreated','y');
INSERT INTO dbo.StatusValues VALUES  ('1','draft','y');
INSERT INTO dbo.StatusValues VALUES  ('4','submitted','y');
INSERT INTO dbo.StatusValues VALUES  ('7','submittedforagiv','y');
INSERT INTO dbo.StatusValues VALUES  ('5','rejected','y');
INSERT INTO dbo.StatusValues VALUES  ('8','approvedbyagiv','y');
INSERT INTO dbo.StatusValues VALUES  ('9','rejectedbyagiv','y');
INSERT INTO dbo.StatusValues VALUES  ('2','approved','y');
INSERT INTO dbo.StatusValues VALUES  ('3','retired','y');
insert into dbo.statusvaluesdes VALUES ('0','dut','Onbekend');
insert into dbo.statusvaluesdes VALUES ('1','dut','Ontwerp');
insert into dbo.statusvaluesdes VALUES ('2','dut','Goedgekeurd door AGIV en gepubliceerd');
insert into dbo.statusvaluesdes VALUES ('3','dut','Gearchiveerd');
insert into dbo.statusvaluesdes VALUES ('4','dut','Intern ingediend');
insert into dbo.statusvaluesdes VALUES ('5','dut','Afgekeurd door Hoofdeditor');
insert into dbo.statusvaluesdes VALUES ('6','dut','Pas gecreëerd');
insert into dbo.statusvaluesdes VALUES ('7','dut','Intern goedgekeurd en ingediend bij AGIV');
insert into dbo.statusvaluesdes VALUES ('8','dut','Klaar voor publicatie');
insert into dbo.statusvaluesdes VALUES ('9','dut','Afgekeurd door AGIV-validator');

ALTER TABLE dbo.metadatastatus
  ADD CONSTRAINT metadatastatus_statusid_fkey FOREIGN KEY (statusid)
      REFERENCES dbo.statusvalues (id);
