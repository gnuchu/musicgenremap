CREATE TABLE genres (id integer primary key autoincrement, name varchar(200));
CREATE TABLE genrehassubgenre(parent_id integer, child_id integer);
CREATE INDEX genrehassubgenre_idx on genrehassubgenre(parent_id, child_id);
