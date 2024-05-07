/*
Las tablas en memoria en SQL Server existen desde la versión 2014
Para que se puedan crear primero hay que habilitarlo en la base de datos
Por supuesto, si el proyecto lo contempla podriamos haberlo habilitado desde un principio
*/

RAISERROR(N'Este script no está pensado para que lo ejecutes "de una" con F5. Seleccioná y ejecutá de a poco.', 20, 1) WITH LOG;
GO

USE [master]
GO

CREATE DATABASE [UnlamBDAplDatosEnMemoria]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PruebasDisco', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\UnlamBDAplDatosEnDisco.mdf' ), 
 FILEGROUP [Memoria] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'PruebasMemoria', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\UnlamBDAplDatosEnMemoria.mdf' )
 LOG ON 
( NAME = N'Pruebas_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\UnlamBDAplDatosEnMemoria_log.ldf'  )
GO


/*
Sino tenemos que modificar la DB:

ALTER DATABASE PruebasDB
	ADD  FILEGROUP [Memoria] CONTAINS MEMORY_OPTIMIZED_DATA 
go

alter database pruebasDB
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
go

*/
use UnlamBDAplDatosEnMemoria
go

create schema ddbba
go

-- Ahora podemos indicar al crear una tabla
-- si se almacenará en memoria o no
-- y si queremos que persista o no

drop table ddbba.UnlamBDAplDatosEnMemoria

IF OBJECT_ID(N'[ddbba].[UnlamBDAplDatosEnMemoria]', N'U') IS NULL 
	create table ddbba.UnlamBDAplDatosEnMemoria (
		id		int	identity(1,1) primary key NONCLUSTERED,
		nombre	varchar(35)
	)
	with ( MEMORY_OPTIMIZED = ON
	, DURABILITY =  SCHEMA_ONLY )
else
	print 'Ya existe'
go

/*
No se pueden generar indices cluster en las tablas en memoria.
Por ello debemos aclarar que el PK es nonclustered
La clausula WITH es la que determina que se almacena en memoria 
Por default la durabilidad (persistencia) es para esquema y datos
Pero si queremos mantener solo la estructura de la tabla, lo
indicamos con SCHEMA_ONLY (definicion de campos).
*/

drop table ddbba.UnlamBDAplDatosEnMemoriaPersistente
go

IF NOT EXISTS (
    SELECT * FROM sys.tables t 
    JOIN sys.schemas s ON (t.schema_id = s.schema_id) 
    WHERE s.name = 'ddbba' AND t.name = 'PruebaEnMemoriaPersistente') 
begin
	create table ddbba.UnlamBDAplDatosEnMemoriaPersistente (
		id		int	identity(1,1) primary key nonclustered,
		nombre	varchar(35)
	)
	with ( MEMORY_OPTIMIZED = ON
	, DURABILITY =  SCHEMA_AND_DATA )
end

exec sp_help 'ddbba.UnlamBDAplDatosEnMemoriaPersistente'

exec sp_help 'ddbba.UnlamBDAplDatosEnMemoria'

-- Aqui hicimos explicito que queremos conservar los datos
/*
Veamos ahora la prueba, insertemos valores en ambas
*/

insert ddbba.UnlamBDAplDatosEnMemoriaPersistente(nombre)
select 'Chau'

insert ddbba.UnlamBDAplDatosEnMemoria(nombre)
select 'Chau'
-- Constatamos lo que se inserto:
select * from ddbba.UnlamBDAplDatosEnMemoriaPersistente
select * from ddbba.UnlamBDAplDatosEnMemoria
go



/* Ahora habria que reiniciar el servicio SQL Server
 (para no reiniciar el sistema operativo, que es medio violento e innecesario)

 Una vez que haya reiniciado, conectese nuevamente a la DB y ejecute a partir de aqui
 No es necesario que cierre SSMS

 */
 -- esto detiene el motor:
 shutdown

 -- en este punto tendrias que iniciar el servicio SQL Server de nuevo.

use pruebasDB
go
exec sp_help 'ddbba.PruebaEnMemoriaPersistente'

use Probanding
go
-- por default tal vez su usuario no use esta DB al conectarse

-- Veamos que nos quedo:
select * from ddbba.PruebaEnMemoriaPersistente
select * from ddbba.PruebaEnMemoria

select @@servername

use pruebasdb
go
-- Ahora creemos una tabla temporal
Create table #temporal
(
	a int primary key
	,b varchar(10)
)
-- Guardemos algo
insert #temporal
values (11,'Hoooola')
select @@rowcount [cuenta de afectadas]
set nocount on
-- ¿En qué DB la generó?
select * from #temporal
-- Tip: busque System Databases -> tempdb -> Temporary Tables

-- ¿Por qué le agrega un sufijo al nombre de la tabla?
-- ¿Qué pasa si varios usuarios crean la misma temporal?

-- ¿Y si le especificamos un esquema? 
-- Porque a ddbba no lo creamos en tempdb...
Create table ddbba.#temporalisima
(
	a int primary key
	,b varchar(10)
)
-- ¿En qué base lo creó? ¿Con qué esquema?
-- ¿Esto va a funcionar:
Create table ddbba.#temporal
(
	a int primary key
	,b varchar(10)
)
-- Veamos ahora el alcance:
select * from #temporal
select * from pruebasdb.dbo.#temporal
select * from Probanding.dbo.#temporal
select * from [AdventureWorks2017].dbo.#temporal
-- Es la misma tabla! 

-- Qué pasa si intentamos verla desde OTRA SESION de usuario?
-- (genere una conexión distinta y verifique)
--

-- Veamos qué pasa con una temporal global (observe el doble numeral):
Create table ##temporalGlobal
(
	a int primary key
	,b varchar(20)
)

-- Guardemos algo
insert ##temporalGlobal
values (1,'Flaaanders')

-- Observe la tabla temporal creada en tempdb.
-- ¿Se modificó el nombre de la tabla para distinguirla entre sesiones? ¿Por qué?

-- Ahora verifique nuevamente desde una conexion distinta (mismo usuario o distinto)

-- ¿Cuanto tiempo perduran las tablas temporales?
-- Desconectese del motor y vuelva a conectarse
-- Verifique a qué temporales tiene acceso.

-- Veamos ahora el alcance:
select * from #temporal
select * from ##temporalGlobal

/*
Ejecute lo siguiente en la otra sesion:

begin tran
delete from ##temporalGlobal

Verifique que la tabla aun existe

Abra una nueva sesion
Ejecute
select * from ##temporalGlobal

Ahora:
cierre la conexion original
ejecute un COMMIT TRAN en la segunda ventana.
¿qué pasó con la temporal?
*/

--------------------------------------------------------------------------------------------


use pruebasDB
go

/*
Veamos un JSON de ejemplo
Fuente: https://infra.datos.gob.ar/catalog/modernizacion/dataset/7/distribution/7.2/download/provincias.json

{"provincias":[{"nombre_completo":"Provincia de Misiones","fuente":"IGN","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}

*/

Declare @jsonProvincias nvarchar(max);
set @jsonProvincias = N'{"provincias":[{"nombre_completo":"Provincia de Misiones","fuente":"IGN","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}';
SELECT * FROM OpenJson(@jsonProvincias);

/*
El esquema default devuelve tres campos: key, value y type
Type column	JSON data type
0	null
1	string
2	int
3	true/false
4	array
5	object

La funcion OPENJSON no funciona con DB con nivel de compatibilidad inferior a 130
*/

-- Muy dificil... empecemos con algo mas simple:
DECLARE @jsonSimple NVarChar(2048) = N'{
"Equipo": "Boca",
"Categoria": "Primera",
"Goles": 99999,
"Colores": "Azul y amarillo",
"DT": null
}'

SELECT * FROM OpenJson(@jsonSimple)
WITH (
Nombre VARCHAR(100) '$.Equipo',
Categoria varchar(50) '$.Categoria',
Contador int '$.Goles',
Casaca VARCHAR(100) '$.Colores',
Tecnico NVARCHAR(200) '$.DT'
)

-- Si el JSON contiene un array o un objeto, debemos indicar que el campo se interpreta "AS JSON"

DECLARE @jsonMenosSimple NVarChar(2048) = N'{
"Equipo": "Boca",
"Categoria": "Primera",
"Goles": 99999,
"Colores": [ "azul", "amarillo", "violeta" ],
"DT": null
}'
SELECT * FROM OpenJson(@jsonMenosSimple)
WITH (
Nombre VARCHAR(100) '$.Equipo',
Categoria varchar(50) '$.Categoria',
Contador int '$.Goles',
Casaca NVARCHAR(max) '$.Colores' as JSON,	-- si es un json en un json, es nvarchar(max)
Tecnico NVARCHAR(200) '$.DT'
)

-- Pero nos gustaria ver los colores como campos
DECLARE @jsonMenosSimple NVarChar(2048) = N'{
"Equipo": "Boca",
"Categoria": "Primera",
"Goles": 99999,
"Colores": [ "azul", "amarillo", "violeta" ],
"DT": null
}'
select Club,Torneo,Color from OPENJSON(@jsonMenosSimple)
WITH( 
Club VARCHAR(20) '$.Equipo' ,
Torneo VARCHAR(20) '$.Categoria',
Casaca nvarchar(MAX)  '$.Colores' AS JSON)
	CROSS APPLY OPENJSON(Casaca) WITH (
		Color VARCHAR(20) '$')

-- Apliquemos lo que aprendimos y veamos los datos de las provincias
-- como tabla (no uso todos los datos)
Declare @jsonProvincias nvarchar(max);
set @jsonProvincias = N'{"provincias":[{"nombre_completo":"Provincia de Misiones","fuente":"IGN","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}';
select Nombre, Fuente, id, Categoria 
from OPENJSON(@jsonProvincias)
WITH( 
	provincias nvarchar(max) '$.provincias' as JSON)
	cross apply openjson(provincias) with (
		Nombre varchar(30) '$.nombre_completo',
		Fuente varchar(30) '$.fuente',
		id int '$.id',
		Categoria varchar(30) '$.categoria')
		
-- otra forma, observar que cambia el openjson y simplificamos un CROSS APPLY
Declare @jsonProvincias nvarchar(max);
set @jsonProvincias = N'{"provincias":[{"nombre_completo":"Provincia de Misiones","fuente":"IGN","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}';
select * 
from OPENJSON(@jsonProvincias, '$.provincias')
WITH( 
	Nombre varchar(30) '$.nombre_completo',
	Fuente varchar(30) '$.fuente',
	id int '$.id',
	Categoria varchar(30) '$.categoria')

-- El modo default es LAX (laxo), y si falta un dato no hay problema
-- El modo estricto se indica con el prefijo strict delante del patron de cadena, por ejemplo 
-- Categoria varchar(30) 'strict $.categoria')
-- vamos a quitarle la fuente a la primer provincia
Declare @jsonProvincias nvarchar(max);
set @jsonProvincias = N'{"provincias":[{"nombre_completo":"Provincia de Misiones","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}';
select * 
from OPENJSON(@jsonProvincias, '$.provincias')
WITH( 
	Nombre varchar(30) '$.nombre_completo',
	Fuente varchar(30) '$.fuente',
	id int '$.id',
	Categoria varchar(30) '$.categoria')

-- Ahora observe el modo estricto
Declare @jsonProvincias nvarchar(max);
set @jsonProvincias = N'{"provincias":[{"nombre_completo":"Provincia de Misiones","iso_id":"AR-N","nombre":"Misiones","id":"54","categoria":"Provincia","iso_nombre":"Misiones","centroide":{"lat":-26.8753965086829,"lon":-54.6516966230371}},{"nombre_completo":"Provincia de San Luis","fuente":"IGN","iso_id":"AR-D","nombre":"San Luis","id":"74","categoria":"Provincia","iso_nombre":"San Luis","centroide":{"lat":-33.7577257449137,"lon":-66.0281298195836}},{"nombre_completo":"Provincia de San Juan","fuente":"IGN","iso_id":"AR-J","nombre":"San Juan","id":"70","categoria":"Provincia","iso_nombre":"San Juan","centroide":{"lat":-30.8653679979618,"lon":-68.8894908486844}},{"nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","iso_id":"AR-E","nombre":"Entre Ríos","id":"30","categoria":"Provincia","iso_nombre":"Entre Ríos","centroide":{"lat":-32.0588735436448,"lon":-59.2014475514635}},{"nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","iso_id":"AR-Z","nombre":"Santa Cruz","id":"78","categoria":"Provincia","iso_nombre":"Santa Cruz","centroide":{"lat":-48.8154851827063,"lon":-69.9557621671973}},{"nombre_completo":"Provincia de Río Negro","fuente":"IGN","iso_id":"AR-R","nombre":"Río Negro","id":"62","categoria":"Provincia","iso_nombre":"Río Negro","centroide":{"lat":-40.4057957178801,"lon":-67.229329893694}},{"nombre_completo":"Provincia del Chubut","fuente":"IGN","iso_id":"AR-U","nombre":"Chubut","id":"26","categoria":"Provincia","iso_nombre":"Chubut","centroide":{"lat":-43.7886233529878,"lon":-68.5267593943345}},{"nombre_completo":"Provincia de Córdoba","fuente":"IGN","iso_id":"AR-X","nombre":"Córdoba","id":"14","categoria":"Provincia","iso_nombre":"Córdoba","centroide":{"lat":-32.142932663607,"lon":-63.8017532741662}},{"nombre_completo":"Provincia de Mendoza","fuente":"IGN","iso_id":"AR-M","nombre":"Mendoza","id":"50","categoria":"Provincia","iso_nombre":"Mendoza","centroide":{"lat":-34.6298873058957,"lon":-68.5831228183798}},{"nombre_completo":"Provincia de La Rioja","fuente":"IGN","iso_id":"AR-F","nombre":"La Rioja","id":"46","categoria":"Provincia","iso_nombre":"La Rioja","centroide":{"lat":-29.685776298315,"lon":-67.1817359694432}},{"nombre_completo":"Provincia de Catamarca","fuente":"IGN","iso_id":"AR-K","nombre":"Catamarca","id":"10","categoria":"Provincia","iso_nombre":"Catamarca","centroide":{"lat":-27.3358332810217,"lon":-66.9476824299928}},{"nombre_completo":"Provincia de La Pampa","fuente":"IGN","iso_id":"AR-L","nombre":"La Pampa","id":"42","categoria":"Provincia","iso_nombre":"La Pampa","centroide":{"lat":-37.1315537735949,"lon":-65.4466546606951}},{"nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","iso_id":"AR-G","nombre":"Santiago del Estero","id":"86","categoria":"Provincia","iso_nombre":"Santiago del Estero","centroide":{"lat":-27.7824116550944,"lon":-63.2523866568588}},{"nombre_completo":"Provincia de Corrientes","fuente":"IGN","iso_id":"AR-W","nombre":"Corrientes","id":"18","categoria":"Provincia","iso_nombre":"Corrientes","centroide":{"lat":-28.7743047046407,"lon":-57.8012191977913}},{"nombre_completo":"Provincia de Santa Fe","fuente":"IGN","iso_id":"AR-S","nombre":"Santa Fe","id":"82","categoria":"Provincia","iso_nombre":"Santa Fe","centroide":{"lat":-30.7069271588117,"lon":-60.9498369430241}},{"nombre_completo":"Provincia de Tucumán","fuente":"IGN","iso_id":"AR-T","nombre":"Tucumán","id":"90","categoria":"Provincia","iso_nombre":"Tucumán","centroide":{"lat":-26.9478001830786,"lon":-65.3647579441481}},{"nombre_completo":"Provincia del Neuquén","fuente":"IGN","iso_id":"AR-Q","nombre":"Neuquén","id":"58","categoria":"Provincia","iso_nombre":"Neuquén","centroide":{"lat":-38.6417575824599,"lon":-70.1185705180601}},{"nombre_completo":"Provincia de Salta","fuente":"IGN","iso_id":"AR-A","nombre":"Salta","id":"66","categoria":"Provincia","iso_nombre":"Salta","centroide":{"lat":-24.2991344492002,"lon":-64.8144629600627}},{"nombre_completo":"Provincia del Chaco","fuente":"IGN","iso_id":"AR-H","nombre":"Chaco","id":"22","categoria":"Provincia","iso_nombre":"Chaco","centroide":{"lat":-26.3864309061226,"lon":-60.7658307438603}},{"nombre_completo":"Provincia de Formosa","fuente":"IGN","iso_id":"AR-P","nombre":"Formosa","id":"34","categoria":"Provincia","iso_nombre":"Formosa","centroide":{"lat":-24.894972594871,"lon":-59.9324405800872}},{"nombre_completo":"Provincia de Jujuy","fuente":"IGN","iso_id":"AR-Y","nombre":"Jujuy","id":"38","categoria":"Provincia","iso_nombre":"Jujuy","centroide":{"lat":-23.3200784211351,"lon":-65.7642522180337}},{"nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","iso_id":"AR-C","nombre":"Ciudad Autónoma de Buenos Aires","id":"02","categoria":"Ciudad Autónoma","iso_nombre":"Ciudad Autónoma de Buenos Aires","centroide":{"lat":-34.6144934119689,"lon":-58.4458563545429}},{"nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","iso_id":"AR-B","nombre":"Buenos Aires","id":"06","categoria":"Provincia","iso_nombre":"Buenos Aires","centroide":{"lat":-36.6769415180527,"lon":-60.5588319815719}},{"nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","iso_id":"AR-V","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","id":"94","categoria":"Provincia","iso_nombre":"Tierra del Fuego","centroide":{"lat":-82.52151781221,"lon":-50.7427486049785}}],"total":24,"cantidad":24,"parametros":{},"inicio":0}';
select * 
from OPENJSON(@jsonProvincias, '$.provincias')
WITH( 
	Nombre varchar(30) '$.nombre_completo',
	Fuente varchar(30) 'strict $.fuente',
	id int '$.id',
	Categoria varchar(30) '$.categoria')
-- Nos da el error "No se puede encontrar la propiedad en la ruta de acceso JSON especificada."

-- Para abrir archivos tenemos una sintaxis similar a OPENXML

SELECT * 
FROM OPENROWSET (BULK 'C:\pruebas\archivo.json', SINGLE_CLOB) as JsonFile
-- Una vez leido el valor de cadena podemos aplicar lo aprendido antes


------------------------------------------------------------------------------------------------------

use UnlamBDAplDatosEnMemoria
go

drop table if exists ddbba.cliente
go

CREATE TABLE ddbba.cliente (
    ID [int]	IDENTITY(1,1) NOT NULL,
    Documento	varchar(20) NOT NULL,
    Nombre		varchar(50) NOT NULL,
    Direccion	varchar(50)  NULL,
    Ocupacion	varchar(50) NOT NULL,
 CONSTRAINT ClientePK PRIMARY KEY (Id)
)
GO

/* Este archivo guardelo como "clientes.xml" 

<?xml version="1.0" encoding="utf-8"?>
<Clientes>
  <Cliente>
    <Documento>300 000 000</Documento>
    <Nombre>Ponzio</Nombre>
    <Direccion>Belgrano 2011</Direccion>
    <Ocupacion>Sufridor</Ocupacion>
  </Cliente>
  <Cliente>
    <Documento>300 000 001</Documento>
    <Nombre>JJ Lopez</Nombre>
    <Direccion>Belgrano 0626</Direccion>
    <Ocupacion>Conductor</Ocupacion>
  </Cliente>
  <Cliente>
    <Documento>300 000 002</Documento>
    <Nombre>Sanfilippo Jose</Nombre>
    <Direccion>Almagro</Direccion>
    <Ocupacion>Cajero</Ocupacion>
  </Cliente>
  <Cliente>
    <Documento>300 000 003</Documento>
    <Nombre>Pipi Romagnoli</Nombre>
    <Direccion>Boedo</Direccion>
    <Ocupacion>Repositor</Ocupacion>
  </Cliente>
  <Cliente>
    <Documento>300 000 004</Documento>
    <Nombre>Ruben Insua</Nombre>
    <Direccion>Flores</Direccion>
    <Ocupacion>Responsable At. al cliente</Ocupacion>
  </Cliente>
</Clientes>

*/

-- Primer opción: cargar el archivo en una tabla

INSERT INTO ddbba.Cliente (documento, nombre, direccion, Ocupacion)
	SELECT
	   XMLClientes.Cliente.query('Documento').value('.', 'VARCHAR(20)'),
	   XMLClientes.Cliente.query('Nombre').value('.', 'VARCHAR(50)'),
	   XMLClientes.Cliente.query('Direccion').value('.', 'VARCHAR(50)'),
	   XMLClientes.Cliente.query('Ocupacion').value('.', 'VARCHAR(50)')
	FROM (SELECT CAST(XMLClientes AS xml)
		  FROM OPENROWSET(BULK 'C:\pruebas\Clientes.xml', SINGLE_BLOB) AS T(XMLClientes)) AS T(XMLClientes)
		  CROSS APPLY XMLClientes.nodes('Clientes/Cliente') AS XMLClientes (Cliente);


-- Otra forma
-- Vamos a cargar el XML como cadena en una tabla primero (observe el tipo de dato XML)

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'XMLCrudo' AND TABLE_SCHEMA = 'ddbba')
   DROP TABLE ddbba.XMLCrudo;

-- podes leer sobre varias formas de verificar si existe una tabla (u objeto) antes de borrarlo aqui:
-- https://www.mssqltips.com/sqlservertip/6769/sql-server-drop-table-if-exists/

CREATE TABLE ddbba.XMLCrudo
(
	Id INT IDENTITY PRIMARY KEY,
	XMLData XML,
	FechaHoraCarga DATETIME	-- Solo informativo
)

INSERT INTO ddbba.XMLCrudo(XMLData, FechaHoraCarga)
	SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
	FROM OPENROWSET(BULK 'C:\pruebas\Clientes.xml', SINGLE_BLOB)  x;

-- (1) a partir de aqui ejecutamos en bloque
DECLARE @XML AS XML, 
	@hDoc AS INT, 
	@SQL NVARCHAR (MAX)

SELECT @XML = XMLData 
			FROM ddbba.XMLCrudo

-- Se almacena en una cache interna (ver que luego se debe liberar)
EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML
-- Observar que la variable @hDoc es un handle, y se utilizó como variable de salida en la llamada al SP
-- OpenXML es una función utilizada en el FROM.
SELECT *
FROM OPENXML(@hDoc, 'Clientes/Cliente')
WITH 
(
	Documento [varchar](50) 'Documento',
	Nombre [varchar](100) 'Nombre',
	Direccion [varchar](100) 'Direccion',
	Ocupacion [varchar](100) 'Ocupacion'
)
-- liberamos la memoria usada
EXEC sp_xml_removedocument @hDoc
--- (1) hasta aqui



/*
mas info en
https://www.red-gate.com/simple-talk/databases/sql-server/learn/using-the-for-xml-clause-to-return-query-results-as-xml/
https://www.sqlshack.com/for-xml-path-clause-in-sql-server/
*/


select * 
from ddbba.cliente
for xml RAW;
-- la forma más básica hace que cada fila sea un ROW en un XML genérico
-- y cada campo es un atributo de ese elemento XML

-- Supongamos que no nos gusta ver que cada fila se llama row (fila en inglés)
select * 
from ddbba.cliente
for xml RAW ('Cliente');
-- ahora cada fila es un Cliente.

-- Si queremos que además tenga una raiz lo indicamos... y le ponemos nombre
select * 
from ddbba.cliente
for xml RAW ('Cliente'), ROOT('DocCliente');

-- Si preferimos una forma más simple y similar a la original, 
-- separamos los campos como elementos
select * 
from ddbba.cliente
for xml RAW ('Cliente'), ROOT('DocCliente'), ELEMENTS;

-- Supongamos que uno de los clientes llamado "pipi" ya no tiene barrio
Update ddbba.cliente
set		direccion=null
where	nombre like 'Pipi%'

-- Observe que si hay un valor nulo el elemento no se incluye
select * 
from ddbba.cliente
for xml RAW ('Cliente'), ROOT('DocCliente'), ELEMENTS;

-- A menos que indiquemos una palabra clave:
select * 
from ddbba.cliente
for xml RAW ('Cliente'), ROOT('DocCliente'), ELEMENTS XSINIL;
-- Ahora el nulo aparece indicado
-- pero además veremos en el elemento raiz que se indica el esquema default

-- Podemos especificar que además del esquema aparezcan los tipos de datos
select * 
from ddbba.cliente
for xml RAW ('Cliente'), ROOT('DocCliente'), ELEMENTS,XMLSCHEMA;

-- En lugar de utilizar la alternativa RAW veamos la opcion AUTO
select * 
from ddbba.cliente
for xml auto, ROOT('DocCliente'), ELEMENTS XSINIL;
-- Observe que no se indica el nombre de la fila

-- Hagamos algo un poquito mas interesante
-- Supongamos que registramos una tabla relacionada
create table ddbba.gol (
	fecha	smalldatetime,
	rival	char(15),
	idCliente	int references ddbba.cliente (id))

insert ddbba.gol
	select '01/01/1971','Flamengo',1
	union
	select '01/01/1981','Racing',2
	union			
	select '01/01/1982','Inter',2
	union			
	select '01/01/1983','Nacional',3
	union
	select '01/01/1974','Palmeiras',3
	union
	select '01/02/1971','Peñarol',3
	union
	select '01/04/1971','Cruzeiro',1

-- Observe ahora como se presentan los registros relacionados en la vista XML
SELECT Jugador.Nombre, Jugador.ID,
	Jugador.Direccion, Gol.rival, gol.fecha
FROM ddbba.cliente Jugador 
   INNER JOIN ddbba.gol Gol
   ON Jugador.id = Gol.idCliente
FOR XML AUTO, ROOT ('Cliente'), ELEMENTS XSINIL; 

-- Otra forma similar de presentar lo mismo
-- Note la subconsulta en el SELECT
SELECT Jugador.Nombre, Jugador.ID,
	(	select Gol.rival, gol.fecha 
		from	ddbba.gol 
		where	gol.idCliente = Jugador.id
		FOR	XML AUTO, TYPE, ELEMENTS)
FROM ddbba.cliente Jugador 
FOR XML AUTO; 

-- Hay mucho mas que se puede lograr...

--------------------------------------------------------------------------------------------------


USE pruebasDB
GO

/*
IMPORTANTE:
No recomendamos el uso en productivo de SQL Server para acceso a APIs web 
Existen muchas alternativas para hacerlo de muchisimas maneras distintas
con otros lenguajes mucho mas amigables y avanzados.

Dado que la materia DDBBA la pueden cursar sin haber avanzado tanto en
programacion, incluimos esta guia para darles un primer contacto con las
API con el lenguaje que van conociento: T-SQL.

Ademas... esta re copado.

Para ejecutar un llamado a una API desde SQL primero vamos a tener que 
habilitar ciertos permisos que por default vienen bloqueados.
En este caso, 'Ole Automation Procedures' permite a SQL Server 
utilizar el controlador OLE para interactuar con los objetos COM.
(excede el alcance de la materia profundizar sobre OLE y objetos COM,
que por otra parte están bastante obsoletos)
*/

EXEC sp_configure 'show advanced options', 1;	--Este es para poder editar los permisos avanzados.
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;	-- Aqui habilitamos esta opcion avanzada
RECONFIGURE;
GO

--	Para empezar vamos a utilizar una API pública que devuelve la hora
--  Muchas API publicas requieren un token que obtenemos al registrarnos
--	Pero esta no... por eso nos gustó
--	Referencia: https://www.worldtimeapi.org

--	Armamos el URL del llamado tal como hallamos en la doc de la API
DECLARE @ruta NVARCHAR(64) = 'https://www.worldtimeapi.org/api/timezone'
DECLARE @continente NVARCHAR(64) = 'America'
DECLARE @pais NVARCHAR(64) = 'Argentina'
DECLARE @provincia NVARCHAR(64) = 'Cordoba'
DECLARE @url NVARCHAR(256) = CONCAT(@ruta, '/', @continente, '/', @pais, '/', @provincia)
-- Observe que podemos usar CONCAT para concatenar strings, tambien lo hemos hecho con el operador +
-- Nos queda asi:
PRINT @url
-- En vez de hacer un print y verlo en la consola, podemos guardar 
-- el llamado en un log y revisar el mismo si el sistema no funciona como queremos.

-- Esto lo podemos comparar con la referencia de https://www.worldtimeapi.org/pages/examples
-- (ahora ejecutar hasta el siguiente GO)
DECLARE @Object INT
DECLARE @json TABLE(respuesta NVARCHAR(MAX))	-- Usamos una tabla variable
DECLARE @respuesta NVARCHAR(MAX)

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT	-- Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' -- Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
EXEC sp_OAMethod @Object, 'SEND' 
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --, @json OUTPUT -- Señalamos donde vamos a guardar la respuesta.

-- Observe que si el SP devuelve una tabla lo podemos almacenar con INSERT
INSERT @json 
	EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' -- Obtenemos el valor de la propiedad 'RESPONSETEXT' del objeto OLE luego de realizar la consulta.

SELECT respuesta FROM @json
Go


-- Perfecto, confirmamos que funciona y recibimos datos,
-- nos resta darle a ese json una forma que nos sea útil
-- Repetiremos el codigo y agregamos la interpretacion del JSON
DECLARE @ruta NVARCHAR(64) = 'https://www.worldtimeapi.org/api/timezone'
DECLARE @continente NVARCHAR(64) = 'America'
DECLARE @pais NVARCHAR(64) = 'Argentina'
DECLARE @provincia NVARCHAR(64) = 'Cordoba'
DECLARE @url NVARCHAR(256) = CONCAT(@ruta, '/', @continente, '/', @pais, '/', @provincia)
DECLARE @Object INT
DECLARE @json TABLE(DATA NVARCHAR(MAX))
DECLARE @respuesta NVARCHAR(MAX)

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
EXEC sp_OAMethod @Object, 'SEND'
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT , @json OUTPUT

-- esta es la sintaxis para insertar una tabla devuelta por un SP 
INSERT INTO @json 
	EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
SELECT * FROM OPENJSON(@datos)
WITH
(
	[Datetime2] datetime2 '$.datetime',
	[FechaHoraISO] nvarchar(40) '$.datetime',
	[Dia del año] int '$.day_of_year',
	[Dia de la semana] int '$.day_of_week',
	[UTC Offset] nvarchar(30) '$.utc_offset'
);
-- Observe que usamos datetime2 porque datetime esta limitada en el rango de años
-- El formato FechaHoraISO es estandar
go

-- Para el siguiente ejemplo vamos con una API que nos sirva un poco más, esta API gratuita de traducción:
-- Fuente: https://mymemory.translated.net/doc/

-- Como con la anterior, vamos a empezar armando el URL, 
-- lo que vamos a necesitar parametrizar es la frase a traducir, el idioma y a que idioma queremos.
DECLARE @ruta NVARCHAR(64) = 'https://api.mymemory.translated.net/get?'
DECLARE @fraseOriginal NVARCHAR(256) = 'How odd to watch a mortal kindle, then to dwindle day by day, knowing their bright souls are tinder, and the wind will have its way'
DECLARE @idiomaOriginal NVARCHAR(8) = 'en'
DECLARE @idiomaTraduccion NVARCHAR(8) = 'es-es'
DECLARE @url NVARCHAR(336) = CONCAT(@ruta, 'q=', @fraseOriginal, '&langpair=', @idiomaOriginal, '|', @idiomaTraduccion)

PRINT @url
-- Ejecutamos hasta aqui si solo queremos ver la URL armada con la consulta
-- Sugerencia: pruebe esa misma URL en Postman

DECLARE @Object INT
DECLARE @json TABLE(DATA NVARCHAR(MAX))
DECLARE @respuesta NVARCHAR(MAX)

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
EXEC sp_OAMethod @Object, 'SEND'
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT, @json OUTPUT

INSERT INTO @json 
	EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
SELECT * FROM OPENJSON(@datos)
WITH
(
	[Frase traducida] NVARCHAR(256) '$.responseData.translatedText',
	[Fidelidad] real '$.responseData.match'
);
go

-- Finalmente un ejemplo con una API falsa:
-- https://jsonplaceholder.typicode.com
-- Lo interesante de este ejemplo es como pasarle los parametros, 
-- los dos anteriores eran ejemplos de llamadas GET donde el parametro 
-- va en la url, pero no tiene porque ser así.

DECLARE @url NVARCHAR(64) = 'https://jsonplaceholder.typicode.com/posts'
DECLARE @Object INT
DECLARE @respuesta NVARCHAR(MAX)
DECLARE @json TABLE(DATA NVARCHAR(MAX))
DECLARE @body NVARCHAR(MAX) = 
'{
	"title": "Titulo de prueba",
	"body": "Esto es una prueba.",
	"userId": 1
}'

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'POST', @url, 'FALSE' -- Cambiamos el metodo de GET a POST.
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json' -- Agregamos el header que indica que la solicitud viene con un body json.
EXEC sp_OAMethod @Object, 'SEND', NULL, @body -- Enviamos la solicitud y el body.
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --, @json OUTPUT

INSERT INTO @json EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
SELECT * FROM OPENJSON(@datos)
WITH
(
	[Titulo] NVARCHAR(256) '$.title',
	[Cuerpo] NVARCHAR(256) '$.body',
	[User Id] int '$.userId',
	[Id] int '$.id'
);