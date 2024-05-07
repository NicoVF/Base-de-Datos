create database UnlamBDApl
go

use UnlamBDApl
go

create schema ddbba
go

create table ddbba.Venta
(
	id int identity(1,1) primary key,
	fecha smalldatetime,
	ciudad char(20),
	monto decimal(10,2)
)
go

-- suprimo los mensajes de "registro insertado"
set nocount on
-- generemos algunos valores al azar
declare @contador int
	, @FechaInicio date
	, @FechaFin date
	, @DiasIntervalo int

-- inicializo valores y limites
SELECT  @FechaInicio = '20230101',
		@FechaFin = '20230731',
		@DiasIntervalo = (1+DATEDIFF(DAY, @FechaInicio, @FechaFin)),
		@contador = 0

-- las ciudades las hardcodie. Genero otro random y lo convierto
while @contador < 1000
begin
	insert ddbba.Venta (fecha, ciudad, monto)
		select DATEADD(DAY, RAND(CHECKSUM(NEWID()))*@DiasIntervalo,@FechaInicio),
			case Cast(RAND()*(5-1)+1 as int)
				when 1 then 'Buenos Aires'
				when 1 then 'Rosario'
				when 1 then 'Bariloche'
				when 1 then 'Claromeco'
				else 'Iguazu'
				end,
				cast(RAND()*(2000-100)+100 as int)
	set @contador = @contador + 1
	print 'Generado el registro nro ' + cast(@contador as varchar)
end
		
-- Podemos dar una mirada a los primeros registros
select top 20 * from ddbba.Venta

-- Si no nos gusta... borramos y generamos de nuevo
-- truncate table ddbba.Venta

-- Ventas promedio por ciudad y fecha
select fecha, ciudad, avg(monto) VentaPromedio
from ddbba.Venta
group by fecha, ciudad

-- Queremos ver cada venta y el promedio por dia
select id, fecha, ciudad, monto, sum(monto) OVER (PARTITION BY ciudad order by fecha) as TotalAcumladoPorDia
from ddbba.Venta
order by ciudad,fecha

-- Ahora cada venta y el acumulado diario
select id, fecha, ciudad, monto, sum(monto) OVER (PARTITION BY ciudad order by fecha) as TotalAcumuladoPorDia
from ddbba.Venta
order by ciudad, fecha

-- Ahora las ventas clasificadas segun el percentil de ventas
-- Permite ver las ventas en una escala de N rangos
/*
percentil:

El percentil nos permite saber como esta situado un valor
en funcion de una muestra
Se toma como medida estadistica, la cual divide una serie de datos
ordenados de menor a mayor en cien partes iguales
*/

select id, fecha, ciudad, monto, ntile(4) OVER (order by monto) as EscalaVentas
from ddbba.venta
order by EscalaVentas,Monto

WITH Fibonacci (PrevN, N) AS
(
	SELECT 0, 1
	UNION ALL
	SELECT N, PrevN + N
	FROM Fibonacci
	WHERE N < 1000
)

SELECT PrevN as Fibo
	FROM Fibonacci
	OPTION (MAXRECURSION 0);


-- Generemos registros de notas de examen de un par de alumnos

IF OBJECT_ID(N'ddbba.Nota', N'U') IS NOT NULL
	DROP TABLE ddbba.Nota;
GO

-- o mas simple
-- DROP TABLE IF EXISTS ddbba.nota;

create table ddbba.Calificacion
(
	id int identity(1,1) primary key,
	materia char(20),
	alumno char(20),
	nota tinyint
	)
go

-- suprimo los mensjaes de "registro insertado"
set nocount on
-- generamos algunos valores al azar
declare @contador int,
		@limiteSuperior int,
		@limiteInferior int
-- inicializo valores y limites
set @contador = 0
set @limiteSuperior = 1
set @limiteInferior = 10
-- Genero otro random y lo convierto
while @contador < 100
begin
	insert ddbba.calificacion (materia, alumno, nota)
		select
			case Cast(RAND()*(3-1)+1 as int)
				when 1 then 'Filiologia'
				when 2 then 'Hermeneutica'
				else 'Reposteria'
				end,
			case Cast(RAND()*(5-1)+1 as int)
				when 1 then 'Juan Bochazo'
				when 2 then 'Carlos Obresaliente'
				when 3 then 'Jose Raspanding'
				when 4 then 'Eugenia Losetodo'
				else 'Lola Mento'
				end,
				cast(RAND()*(@limiteSuperior-@limiteInferior)+@limiteInferior as int)
	set @contador = @contador + 1
	-- print 'Generador el registro nro ' + cast(@contador as varchar)
end
-- le damos una mirada
select top 20 * from ddbba.Calificacion


-- Combinemos un poco
-- Quiero ver el 25% superior de promedios
select materia, alumno, promedio, EscalaNotas
From ( 
	select materia, alumno, promedio, ntile(4) OVER (PARTITION BY materia order by promedio desc) as
		EscalaNotas
	from (
		select alumno, materia, avg(nota) Promedio
		from ddbba.Calificacion
		group by alumno, materia) promedios
		) A
WHERE EscalaNotas = 4

-- y lo mismo con notacion CTE:
with NotasEscaladas (materia, alumno, promedio, escala) as
	(select materia, alumno, promedio, ntile(4) OVER (partition by materia order by promedio asc) as
	Escala
from (select alumno, materia, avg(nota) Promedio
	from ddbba.Calificacion
	group by alumno,materia) promedios
	)
select * from NotasEscaladas where escala=4


WITH CTE(alumno, nota, materia, duplicadas)
as (select alumno, nota, materia, ROW_NUMBER() OVER (PARTITION BY alumno, nota, materia ORDER BY ID)
as duplicadas FROM ddbba.Calificacion)

SELECT *
FROM CTE
WHERE duplicadas > 1

-- y si no hubiera un campo ID unico?
alter table ddbba.Calificacion
	drop column id;
-- hay una restriccion, no se puede borrar!
-- y como se llama esa constraint?

-- ver el nombre de la constraint pk generador automaticamente
select name
from sys.key_constraints
WHERE type = 'PK' and OBJECT_NAME(parent_object_id) = N'Calificacion';
go

-- Eliminar la constraint de PK (revisar el nombre generado)
-- SUGERENCIAl probar SIN los corchetes
ALTER TABLE ddbba.Calificacion
DROP CONSTRAINT PK__Califica__3213E83F9E328C11
GO

-- ahora veamos como manejar las duplicadas
-- incluso sin un ID unico
WITH CTE(alumno, nota, materia, Ocurrencias)
as (select alumno, nota, materia, ROW_NUMBER() OVER (
													PARTITION BY alumno, nota, materia 
													ORDER BY alumno, nota, materia
													) AS AcaPuedoPonerCualquierCosa
	FROM ddbba.Calificacion)
SELECT *
FROM CTE
WHERE Ocurrencias>1;

-- Esto funcionara asi?
delete
from CTE
where Ocurrencias>1;

-- Tenemos que definir el CTE nuevamente!
set nocount off
WITH CTE(alumno, nota, materia, Ocurrencias) 
	as (SELECT alumno, nota, materia, 
				ROW_NUMBER() OVER (
									PARTITION BY alumno, nota, materia
									ORDER BY alumno, nota, materia
									) AS Ocurrencias
		FROM ddbba.Calificacion)

delete 
from CTE
where Ocurrencias > 1;


/*
Un ejemplo mas de CTE en accion
Quiero los promedios por materia, cada materia en una columna
Ob serve que las subconsultas se interpretan de forma mas simple
*/

with NotasFilologia (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.Calificacion
	where materia='Filiologia'
	group by alumno)
,
NotasHermeneutica (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.Calificacion
	where materia = 'Hermeneutica'
	group by alumno)
,
NotasReposteria (alumno, promedio)
as
	(select alumno, avg(nota) promedio
	from ddbba.Calificacion
	where materia = 'Reposteria'
	group by alumno)
-- Al hacer join por alumno hay filas repetidas porque se dan coincidencias
-- multiples en el producto cartesiano

select distinct N.alumno, NF.promedio Filologia, NH.promedio Hermeneutica, NR.promedio Reposteria
from ddbba.Calificacion N
			left join NotasFilologia NF on N.alumno = NF.alumno
			left join NotasHermeneutica NH on N.alumno = NH.alumno
			left join NotasReposteria NR on N.alumno = NR.alumno
order by N.alumno


-----------------------------------------------------------

select top 10 * from ddbba.Venta

-- Note que el CTE simplifica la consulta
with VentasResumidas (Total, Ciudad, Mes) as (
	select monto, ciudad, 
	--cast(datepart(mm,fecha) as varchar) + '-' + cast(datepart(yyyy, fecha) as varchar) Mooos
	cast(month(fecha) as varchar) + '-' + cast(year(fecha) as varchar) Mooos
	from ddbba.Venta)
select *
from VentasResumidas
	pivot(sum(Total) for Mes in ([1-2023],[2-2023],[3-2023],[4-2023],[5-2023],[6-2023],[7-2023]) ) Cruzado



with VentasResumidas (Total, Ciudad, Mes) as (
	select monto, ciudad, 
	--cast(datepart(mm,fecha) as varchar) + '-' + cast(datepart(yyyy, fecha) as varchar) Mooos
	cast(month(fecha) as varchar) + '-' + cast(year(fecha) as varchar) Mooos
	from ddbba.Venta)
select *
from VentasResumidas
	pivot(sum(Total) for Ciudad in ([Iguazu],[Claromeco],[Rosario],[Buenos Aires],[Bariloche])) A


/*
Aspectos a notar:
- Usamos datepart para extraer porciones de la fecha. No es la unica forma.
- El pivot siempre se hace con funciones de agregado.
- Si faltan datos para un valor, genera un NULL.
- El uso de CAST fuerza a la interpretacion como cadena de texto.
- Ese "varchar" admite hasta 30 caraceteres. El casst luego truncara, sino debe indicarse tama;o.
- Usamos corchetes en los valores de columna de PIVOT.
*/


-- Si no queremos usar CTE, podemos usar una subconsulta.

select *
from (select monto, ciudad,
		cast(month(fecha) as varchar) + '-' + cast(year(fecha) as varchar) Mes
	from ddbba.Venta) SubConsultaConNombre
pivot(sum(monto) for Mes in ([1-2023],[2-2023],[3-2023],[4-2023],[5-2023],[6-2023],[7-2023]) ) Cruzado

/*
Necesitamos que el campo para pivot este disponible previamente
Por eso va la subconsulta o la CTE
*/

-- Otro ejemplo. Repasemos la estructura.
create view ddbba.Nota as
	select * from ddbba.Calificacion

/*
Observe que ahoran o es necesaria una subconsulta, el campo "materia" se interpreta tal cual
El uso de la funcion de agregado es obligatorio.
*/

select * from ddbba.Nota
pivot (max(nota) for materia in (Reposteria, Filiologia, Hermeneutica)) A

/*
Que pasa si falta el valor de un cruce?
Veamos
*/

delete from ddbba.Nota
Where alumno='Juan Bochazo' and materia='Filiologia'

-- a ver que pasa...
select * from ddbba.Nota
pivot (max(nota) for materia in (Reposteria, Filiologia, Hermeneutica)) A

-- Para que no aparezca con NULL

select alumno, isnull(Reposteria,0) Reposteria, isnull(Filiologia,0) Filiologia, isnull(Hermeneutica,0) Hermeneutica
from (
		select *
		from ddbba.nota
		pivot (max(nota) for materia in (Reposteria, Filiologia, Hermeneutica)) A
) B

-- Claramente no es practico codificar los nombres de las materias
-- A;adamos algo de SQL dinamico a la receta

declare @cadenaSQL nvarchar(max)
set @cadenaSQL = 'select alumno '
-- Select opera en forma iterativa. Notar que no necesito nada extra para concatenar
-- Cuando usamos COALESCE es porque al principio la variable puede tener NULL y concatenar con NULL, da NULL
select @cadenaSQL = @cadenaSQL + ', isnull(' + rtrim(materia) + ',0)' + rtrim(materia)
from ddbba.nota
group by materia

set @cadenaSQL = @cadenaSQL + ' From (
	select *
	from ddbba.nota
	pivot (max(nota) for materia in ('
select @cadenaSQL = @cadenaSQL + rtrim(materia) + ','
from ddbba.Nota
group by materia

-- saco una coma "extra" con funciones de cadena
set @cadenaSQL = left(@cadenaSQL, len(@cadenaSQL)-1) + ')) A ) B'

-- la vieja confiable del debugging del sql dinamico
-- print @cadenaSQL
execute sp_executesql @cadenaSQL;




/*
Empecemos con algo bien simple e incorrecto
*/

declare @stringSQL nvarchar(200)
declare @monto decimal (10,2)
set @monto = '1000'
set @stringSQL = 'Select fecha, ciudad, monto from ddbba.venta where monto > '
	+ cast(@monto as varchar) + ' order by fecha'
print @stringSQL
exec (@stringSQL)

/*
Observe que la variable @monto tuvimos que convertirla a cadena de texto para poder concatenar todo
Ahora usamos una variable de texto
*/

declare @stringSQL2 nvarchar(200)
declare @ciudad char(20)
set @ciudad = 'Buenos Aires'
set @stringSQL2 = 'Select fecha, ciudad, monto from ddbba.venta where ciudad = ' + @ciudad + ' order by fecha'
print @stringSQL2
exec (@stringSQL2)

/*
Al concatenar el texto se produce un error, necesitamos comillas.
Note que los espacios al final "trailing" no impiden la coincidencia
*/

declare @stringSQL3 nvarchar(200)
declare @ciudad2 char(20)
set @ciudad2 = 'Buenos Aires'
set @stringSQL3 = 'Select fecha, ciudad, monto from ddbba.venta where ciudad = ''' + @ciudad2 + ''' order by fecha'
print @stringSQL3
--exec (@stringSQL3)
select fecha, ciudad, monto from ddbba.venta where ciudad = @ciudad2


/*
Pero se pone interesante con las FECHAS
*/

declare @stringSQL4 nvarchar(200)
declare @fecha smalldatetime
set @fecha = '2/5/2023'
set @stringSQL4 = 'Select fecha, ciudad, monto from ddbba.venta where fecha < ' + @fecha + ' order by fecha'
print @stringSQL4
exec (@stringSQL4)

/*
Ese formato de fecha no le gusto, probemos convertir a texto y ademas usar fecha ISO yyyymmdd
*/

declare @stringSQL5 nvarchar(200)
declare @fecha2 smalldatetime
set @fecha2 = '20230502'
set @stringSQL5 = 'Select fecha, ciudad, monto from ddbba.venta where fecha < ''' 
+ convert(varchar, @fecha2, 103) + ''' order by fecha'
print @stringSQL5
exec (@stringSQL5)

-- Moraleja: cada tipo de dato debe ser convertido a cadena con sus particularidades



/*
Hagamos algo mas interesante. Vamos a generar una consulta para ver la cantidad de filas de cada tabla de la BD.
Esto va a funcionar en cualquier DB SQL SERVER.
Estaremos accediento a tablas de sistema como sys.objects
*/


DECLARE @CadenaSQL NVARCHAR(MAX);
SELECT @CadenaSQL = COALESCE(@cadenaSQL + ' UNION ALL ', '')
			+ 'SELECT '
			+ '''' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
			+ '.' + QUOTENAME(sOBJ.name) + '''' + ' AS [Tabla]
			, COUNT(1) AS [CuentaDeFilas] FROM '
			+ QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
			+ '.' + QUOTENAME(sOBJ.name)
FROM sys.objects as sOBJ
WHERE
	sOBJ.type = 'U' -- significa objeto del usuario, incluiria indices
ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name;
print @CadenaSQL
EXEC sp_executesql @CadenaSQL


select top 100 * from sys.objects