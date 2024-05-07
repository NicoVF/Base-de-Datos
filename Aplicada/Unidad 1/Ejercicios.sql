/*
1. Cree una base de datos con los valores por defecto de crecimiento, ubicaci�n de
archivos, etc. Llame a la misma con su nombre o el de su grupo (si opta por resolver
el TP en grupo).
*/

create database UnlamBDApl
go

use UnlamBDApl
go


/*
2. Cree un esquema denominado �ddbba� (por bases de datos aplicada). Todos los
objetos que cree a partir de aqu� deber�n pertenecer a este esquema o a otro seg�n
corresponda. No debe usar el esquema default (dbo).
*/

create schema ddbba
go


/*
3. Cree una tabla llamada �registro� que tenga los siguientes campos: id entero
autoincremental como primary key; fecha y hora con valor default del momento de
inserci�n, texto con un tama�o m�ximo de 50 caracteres, modulo con un tama�o
m�ximo de 10 caracteres. Esta tabla la emplear� como bit�cora (log) de las
operaciones de los puntos siguientes.
*/

create table ddbba.registro
(
	id int identity(1,1) primary key,
	fecha_hora datetime default(getdate()),
	texto char(50),
	modulo char(50)
)

-- suprimir los mensajes de "registro insertado"
set nocount on
GO

/*
4. Cree un SP llamado �insertarLog� que reciba dos par�metros: modulo y texto. Si el
modulo llega en blanco debe utilizar el texto �N/A�. Este SP insertar� registros en la
tabla de bit�cora. A partir del siguiente punto, cada inserci�n, borrado, modificaci�n,
debe crear un registro en la mencionada tabla. En ning�n caso debe realizar
INSERTs por fuera del SP insertarLog.
*/

CREATE OR ALTER PROCEDURE ddbba.insertarLog
@modulo int,
@texto char(20)
AS
BEGIN
print "a"
END