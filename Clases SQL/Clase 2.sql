USE UnlamBD;

CREATE TABLE Departamento
(
  cod_depto    integer PRIMARY KEY,
  descripcion  varchar(30),
)

CREATE TABLE Empleado
(
  legajo    integer PRIMARY KEY,
  nombre    varchar(30),
  apellido  varchar(30),
  salario   numeric(8,2),
  categoria char(1),
  tel       char(15),
  cod_depto integer FOREIGN KEY REFERENCES Departamento (cod_depto),
)



----
--Filas

INSERT INTO Departamento VALUES (1,'Ventas')

INSERT INTO Departamento VALUES (2,'Compras')

INSERT INTO Departamento VALUES (3,'Administracion')

INSERT INTO Departamento VALUES (4,'Marketing')

INSERT INTO Departamento VALUES (5,'Sistemas')

INSERT INTO Departamento VALUES (6,'Logistica')


INSERT INTO Empleado VALUES (100,'Marcelo','Mendez',120000,'B',null,1)

INSERT INTO Empleado VALUES (101,'Diego','Mancieri',60000,'A','555-1234',2)

INSERT INTO Empleado VALUES (102,'Andrea','Alberti',90000,'C','555-5678',3)

INSERT INTO Empleado VALUES (103,'Janice','Orzechoski',100000,'C',null,4)

INSERT INTO Empleado VALUES (104,'Duilio','Alberti',110000,'A',null,null)

INSERT INTO Empleado VALUES (105,'Mariana','Basile',320000,'A',null,3)

INSERT INTO Empleado VALUES (106,'Ezequiel','Villarreal',160000,'B',null,5)

INSERT INTO Empleado VALUES (107,'Mariano','Michelli',180000,'B',null,5)

INSERT INTO Empleado VALUES (108,'Sebastian','Gonzalez',150000,'C',null,5)

INSERT INTO Empleado VALUES (109,'Exequiel','Alvarez',95000,'C',null,5)

INSERT INTO Empleado VALUES (110,'Tomas','Escovo',320000,'C',null,5)

--------

SELECT * FROM Empleado

SELECT * FROM Departamento

SELECT legajo, nombre, apellido, salario
FROM   Empleado

SELECT legajo, nombre, apellido, salario, categoria
FROM   Empleado
WHERE  salario >= 100000

SELECT legajo, nombre, apellido, salario, categoria
FROM   Empleado
WHERE  salario >= 100000
AND    categoria <> 'B'

SELECT TOP 3 legajo, nombre, apellido, salario  -- primeras 3 filas
FROM   Empleado
ORDER BY salario desc

SELECT distinct apellido -- unicos
FROM   Empleado

SELECT distinct categoria
FROM   Empleado

-----

SELECT *
FROM   Empleado
WHERE  salario NOT BETWEEN 100000 AND 150000  --incluye los extremos

SELECT *
FROM   Empleado
WHERE  tel IS NULL

SELECT *
FROM   Empleado
WHERE  tel IS NOT NULL






SELECT legajo, nombre, apellido, salario
FROM   Empleado

SELECT legajo, nombre, apellido, salario
FROM   Empleado
WHERE  salario >= 100000

SELECT legajo, nombre, apellido, salario, categoria
FROM   Empleado
WHERE  salario >= 100000
AND    categoria <> 'B'

------
--LIKE

SELECT *
FROM   Empleado
WHERE  apellido LIKE '%Z'

SELECT *
FROM   Empleado
WHERE  nombre LIKE 'E_equiel'

--Listar los Empleados de categoria A que tiene un salario inferior a algun otro empleado de categoria B

SELECT *
FROM   Empleado
WHERE  categoria = 'A'
AND    salario < ANY ( SELECT salario FROM Empleado WHERE categoria = 'B' )

--Listar los Empleados de mayor salario

SELECT *
FROM   Empleado
WHERE  salario >= ALL ( SELECT salario FROM Empleado )





-- IN

SELECT *
FROM   Empleado
WHERE  categoria IN ('A','B')

SELECT *
FROM   Empleado
WHERE  categoria = 'A'
OR     categoria = 'B'

SELECT *
FROM   Empleado
WHERE  cod_depto NOT IN (2,3,4)

SELECT *
FROM   Empleado
WHERE  cod_depto IN
(
SELECT cod_depto
FROM   Departamento
WHERE  descripcion IN ('Ventas','Marketing')
)


-- EXISTS

-- Departamentos que donde trabaja al menos un Empleado

SELECT *
FROM   Departamento
WHERE  EXISTS ( SELECT 1
                FROM   Empleado
				WHERE  Empleado.cod_depto = Departamento.cod_depto )

-- Departamentos que donde NO trabaja ningun Empleado

SELECT *
FROM   Departamento d
WHERE  NOT EXISTS ( SELECT *
                    FROM   Empleado e
				    WHERE  e.cod_depto = d.cod_depto )



--UNION (suprime las filas duplicadas)

SELECT legajo, nombre, apellido
FROM   Empleado
WHERE  categoria = 'A'
UNION
-- UNION ALL NO SUPRIME DUPLICADAS
-- INTERSECT
-- EXCEPT -> ESTAN EN 1ERA NO EN 2DA
SELECT legajo, nombre, apellido
FROM   Empleado
WHERE  salario >  100000


---------------

SELECT e.legajo, e.nombre, e.apellido, d.descripcion
FROM   Empleado e, Departamento d
WHERE  e.cod_depto = d.cod_depto
AND    d.descripcion = 'Sistemas'

SELECT e.legajo, e.nombre, e.apellido, d.descripcion
FROM   Empleado e 
FULL JOIN Departamento d
-- LEFT JOIN Departamento d
-- RIGHT JOIN Departamento d
-- INNER JOIN Departamento d
       ON ( e.cod_depto = d.cod_depto )









--UNION ALL

SELECT legajo, nombre, apellido
FROM   Empleado
WHERE  categoria = 'A'
UNION ALL
SELECT legajo, nombre, apellido
FROM   Empleado
WHERE  salario >  100000

----------

SELECT SUM(salario) TOTAL_SALARIOS
FROM   Empleado e
WHERE  categoria = 'A'

SELECT MIN(salario) SALARIO_MINIMO, MAX(salario) SALARIO_MAXIMO
FROM   Empleado
WHERE  cod_depto = 5

SELECT count(*) CANTIDAD_EMPLEADOS
FROM   Empleado
WHERE  cod_depto = 4

SELECT d.descripcion, sum(salario) TOTAL_SALARIOS
FROM   Empleado e, Departamento d
WHERE  e.cod_depto = d.cod_depto
GROUP BY d.descripcion
HAVING sum(salario) > 200000

SELECT d.descripcion, count(*) CANT_EMPLEADOS
FROM   Empleado e, Departamento d
WHERE  e.cod_depto = d.cod_depto
GROUP BY d.descripcion
ORDER BY CANT_EMPLEADOS

SELECT nombre, apellido, salario, round(salario/490,2) SALARIO_DOLARES
FROM   Empleado
ORDER BY SALARIO_DOLARES

-------------------------------------------------
--COCIENTE


--Tabla ALUMNO
CREATE TABLE ALUMNO
(
DNI      numeric(8,0) PRIMARY KEY,
NOMBRE   varchar(60),
APELLIDO varchar(60),
EMAIL    varchar(60),
)

--Tabla MATERIA
CREATE TABLE MATERIA
(
COD_MATERIA    integer PRIMARY KEY,
NOMBRE_MATERIA varchar(60),
ANIO           integer,
)

--Tabla CURSA
CREATE TABLE CURSA
(
DNI_ALUMNO     numeric(8,0) FOREIGN KEY REFERENCES ALUMNO (DNI),
COD_MATERIA    integer FOREIGN KEY REFERENCES MATERIA(COD_MATERIA),
)

SELECT *
FROM   Materia

SELECT *
FROM   Alumno

INSERT INTO MATERIA VALUES (100,'Analisis Matematico 1',1)
INSERT INTO MATERIA VALUES (101,'Fisica 1',1)
INSERT INTO MATERIA VALUES (102,'Algebra 1',1)

INSERT INTO MATERIA VALUES (200,'Analisis Matematico 2',2)
INSERT INTO MATERIA VALUES (201,'Fisica 2',2)
INSERT INTO MATERIA VALUES (202,'Base de Datos',2)

INSERT INTO MATERIA VALUES (300,'Probabilidad y estadistica',3)
INSERT INTO MATERIA VALUES (301,'Algebra 2',3)
INSERT INTO MATERIA VALUES (302,'Sistemas Operativos',3)

INSERT INTO ALUMNO VALUES (43000001,'Pablo','Costa',null)
INSERT INTO ALUMNO VALUES (43000002,'Natalia','Carrizo',null)
INSERT INTO ALUMNO VALUES (43000003,'Jorge','Varela',null)
INSERT INTO ALUMNO VALUES (43000004,'Maria','Perez',null)

INSERT INTO CURSA VALUES (43000002,100)
INSERT INTO CURSA VALUES (43000002,200)

INSERT INTO CURSA VALUES (43000003,200)
INSERT INTO CURSA VALUES (43000003,201)
INSERT INTO CURSA VALUES (43000003,202)

INSERT INTO CURSA VALUES (43000004,200)
INSERT INTO CURSA VALUES (43000004,201)
INSERT INTO CURSA VALUES (43000004,301)

/*Listar los Alumnos que estan cursando TODAS las materias de 2do anio
COCIENTE

Traducir el enunciado de la siguiente forma:
Listar aquellos Alumnos tales que
NO EXISTE una Materia de 2do anio que
NO esten cursando*/

SELECT *
FROM   Alumno a
WHERE  NOT EXISTS ( SELECT *
                    FROM   Materia m
					WHERE  m.anio = 2
					AND    NOT EXISTS ( SELECT *
					                    FROM   Cursa c
										WHERE  c.dni_alumno = a.dni
										AND    c.cod_materia = m.cod_materia ))

/*Otros ejemplos de Cocientes:
1- Listar los Clientes que compraron en TODAS las Sucursales
2- Listar los Medicos que trabajan en TODOS los Hospitales
3- Listar los Empleados que estan asignado a TODOS los Proyectos

1- Listar aquellos Clientes tales que
   NO EXISTE una Sucursal en la que
   NO hayan comprado

2- Listar los Medicos tales que
   NO EXISTE un Hospital en el que
   NO trabaje

3- Listar los Empleados tales que
   NO EXISTE un Proyecto en el que
   NO esten asignados

--------------------------------------
Hay otras formas de resolver un Cociente:

Contar cuantas materias hay en 2do anio y luego ver cuales alumnos cursan esa cantidad de materias de 2do anio */

SELECT c.dni_alumno, a.nombre, a.apellido
FROM   Cursa c, Materia m, Alumno a
WHERE  c.cod_materia = m.cod_materia
AND    m.anio = 2
AND    a.dni = c.dni_alumno
GROUP BY c.dni_alumno, a.nombre, a.apellido
HAVING count(*) = ( SELECT count(*)
                    FROM   Materia
                    WHERE  anio = 2 )


----------- VISTAS

DROP VIEW Vista1

CREATE VIEW Vista1 (dni, nom, ape) AS
SELECT c.dni_alumno, a.nombre, a.apellido
FROM   Cursa c, Materia m, Alumno a
WHERE  c.cod_materia = m.cod_materia
AND    m.anio = 2
AND    a.dni = c.dni_alumno
GROUP BY c.dni_alumno, a.nombre, a.apellido
HAVING count(*) = ( SELECT count(*)
                    FROM   Materia
                    WHERE  anio = 2 )

SELECT *
FROM   Vista1

--Vista de una vista

CREATE VIEW Emp AS
SELECT legajo, nombre, apellido
FROM   Empleado

SELECT *
FROM   Emp

CREATE VIEW Emp_A AS
SELECT *
FROM   Emp
WHERE  apellido LIKE 'A%'

SELECT *
FROM   Emp_A

DROP VIEW Emp


----- Modificacion de datos a traves de una Vista

SELECT *
FROM   Emp

--Michelli -> Micheli

UPDATE Empleado
SET apellido = 'Micheli'
WHERE legajo =107

SELECT *
FROM   Empleado

--Micheli -> Michelli

SELECT *
FROM   Emp

UPDATE Emp
SET apellido = 'Michelli'
WHERE legajo = 107












