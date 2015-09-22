CREATE TABLE org(
  name TEXT PRIMARY KEY,
  boss TEXT REFERENCES org,
  height INT
);

insert into org (name, boss, height) values ("Derrick", Null,9);
insert into org (name, boss, height) values ("Steve","Derrick",8);
insert into org (name, boss, height) values ("Michael","Steve",7);
insert into org (name, boss, height) values ("Stuart","Steve",6);
insert into org (name, boss, height) values ("John","Stuart",5);



WITH RECURSIVE
  works_for_derrick(n) AS (
    VALUES('Derrick')
    UNION
    SELECT name FROM org, works_for_derrick
     WHERE org.boss=works_for_derrick.n
  )
SELECT * FROM org
 WHERE org.name IN works_for_derrick;