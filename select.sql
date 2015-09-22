select ghsg.parent_id, ghsg.child_id
from genrehassubgenre ghsg
  join genres g 
    on g.parent_id = ghsg.id


select *
from (
  select g.name "Parent" from genrehassubgenre ghsg join genres g on g.id = ghsg.parent_id
  union
  select g.name "Child" from genrehassubgenre ghsg join genres g on g.id = ghsg.child_id)




select p.id, c.id
from genrehassubgenre ghsg
  join genres p
    on p.id = ghsg.parent_id
  join genres c
    on c.id = ghsg.child_id


insert into genrehassubgenre (parent_id, child_id) select a.id, b.id from genres a, genres b where a.name='Music' and b.name='Rock'