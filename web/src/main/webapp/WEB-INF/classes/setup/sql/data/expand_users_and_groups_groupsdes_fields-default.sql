ALTER TABLE users ALTER COLUMN username TYPE character varying(300);
ALTER TABLE users ALTER COLUMN surname TYPE character varying(256);
ALTER TABLE users ALTER COLUMN name  TYPE character varying(256);
ALTER TABLE users ALTER COLUMN organisation TYPE character varying(256);
ALTER TABLE users ALTER COLUMN email TYPE character varying(320);
ALTER TABLE groups ALTER COLUMN description TYPE character varying(256);
ALTER TABLE groupsdes ALTER COLUMN label TYPE character varying(256);

