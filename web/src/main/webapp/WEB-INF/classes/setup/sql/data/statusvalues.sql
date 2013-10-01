ALTER TABLE dbo.metadatastatus DROP CONSTRAINT metadatastatus_statusid_fkey;

DELETE FROM dbo.StatusValues;
INSERT INTO dbo.StatusValues VALUES  ('0','unknown','y');
INSERT INTO dbo.StatusValues VALUES  ('1','draft','y');
INSERT INTO dbo.StatusValues VALUES  ('4','submitted','y');
INSERT INTO dbo.StatusValues VALUES  ('2','approved','y');
INSERT INTO dbo.StatusValues VALUES  ('5','rejected','y');
INSERT INTO dbo.StatusValues VALUES  ('3','retired','y');
INSERT INTO dbo.StatusValues VALUES  ('6','justcreated','y');

ALTER TABLE dbo.metadatastatus
  ADD CONSTRAINT metadatastatus_statusid_fkey FOREIGN KEY (statusid)
      REFERENCES dbo.statusvalues (id);
