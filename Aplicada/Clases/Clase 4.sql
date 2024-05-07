/*
Conozcamos los planes de ejecucion.
Puede usar Ctrl+M para ver el plan real
y Ctrl+L para ver el plan estimado
Active además las estadísticas en vivo (menu Query o boton)
*/


use StackOverflow2013
go


-- Conozcamos TABLE SCAN:
select * from pruebasDB.dbo.venta2
-- Es el que veremos en un HEAP
-- Puede que sea buena idea si...
-- la tabla es muy pequeña, un par de cientos de filas
-- hay un ETL en el medio que luego borra la tabla
-- Si no es MALA IDEA...

-- Conozcamos CLUSTERED INDEX SEEK
select * from Users where Id=50
--sp_help users
--alter table users
--	drop constraint PK_Users_Id

select * from Users where Id=50

create clustered index pk_users
	on dbo.users(id)

-- Conozcamos la tabla:
select top 100 * 
from Users
-- Elimino los indices para ver como funciona SIN ellos
drop index ix_displayname on users
drop index ix_displayname_location on users
 
select * 
from Users
where DisplayName like 'John'
-- Anotar COSTO: 


--Habiendo creado este indice
--drop  index ix_DisplayName on users
--go
create nonclustered index ix_DisplayName on users(displayName)

select top 1 * from Users where DisplayName like 'John'


-- Veamos un INDEX SEEK y KEY LOOKUP: 
select id 
from Users
where DisplayName like 'John'


select COUNT(1)
from Users
where DisplayName like 'John'
-- Note que debe buscar en la tabla los datos necesarios




--Supongamos que solo me interesa ver la ubicacion... puedo crear un indice de cobertura para mejorarlo
--drop  index ix_DisplayName on users

create nonclustered index ix_DisplayName_Location 
	on users(displayName) include (location)

select location 
from Users
where DisplayName like 'John'
-- Aqui pudimos ver un  INDEX SEEK (NONCLUSTERED)



-- Quiero ver los posts con mas comentarios (mas populares)
select p.id, p.title, COUNT(c.id) CuentaComentarios
from	dbo.Posts p
		inner join dbo.comments c on p.id=c.postid
group by p.id, p.title
order by count(c.id) desc

create index ix_PostEnComments on dbo.comments(postid)










-- ¿Podemos ver los planes en cache?
-- CLARO QUE PODEMOS
SELECT cplan.usecounts, cplan.objtype, qtext.text, qplan.query_plan
FROM sys.dm_exec_cached_plans AS cplan
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS qtext
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qplan
ORDER BY cplan.usecounts DESC
-- Observe que se indica la cantidad de ejecuciones

-- Si ejecutamos una consulta "ad hoc" en versiones anteriores 
-- veremos que puede que aparezca duplicada si hay diferencias
-- minimas (p/e mayusculas/minusculas en la sintaxis)
select * from dbo.Users where Id=5
select * from dbo.Users Where Id=5

-- en 2017 



-- ¿podemos borrar la cache de planes?
-- POR SUP
DBCC FREEPROCCACHE
