USE UnlamBD

CREATE TABLE Almacen
( Nro int NOT NULL PRIMARY KEY,
Responsable varchar(30))

CREATE TABLE Articulo
( CodArt int NOT NULL PRIMARY KEY,
Descripcion varchar(50),
Precio decimal(12,3)
)

CREATE TABLE Material
(CodMat int NOT NULL PRIMARY KEY,
Descripcion varchar(50))

CREATE TABLE Proveedor
(CodProv int NOT NULL PRIMARY KEY,
Nombre varchar(30),
Domicilio varchar(50),
Ciudad varchar(30))

CREATE TABLE Tiene
(Nro int FOREIGN KEY REFERENCES Almacen(Nro), 
CodArt int FOREIGN KEY REFERENCES  Articulo(CodArt),
PRIMARY KEY (Nro, CodArt))

CREATE TABLE Compuesto_por
(CodArt int FOREIGN KEY REFERENCES Articulo(CodArt),
CodMat int FOREIGN KEY REFERENCES Material(CodMat),
PRIMARY KEY (CodArt,CodMat))

CREATE TABLE Provisto_por
(CodMat int FOREIGN KEY REFERENCES Material(CodMat),
CodProv int FOREIGN KEY REFERENCES Proveedor(CodProv),
PRIMARY KEY (CodMat, CodProv))

INSERT INTO Almacen values
(1, 'Juan Perez'), (2, 'Jose Basualdo'), (3, 'Rogelio Rodriguez')

insert into Articulo values
(1, 'Sandwich JyQ', 5),
(2, 'Pancho', 6),
(3, 'Hamburguesa', 10),
(4, 'Hamburguesa completa', 15)

insert into Material values
(1, 'Pan'),
(2, 'Jamon'),
(3, 'Queso'),
(4, 'Salchicha'),
(5, 'Pan Pancho'),
(6, 'Paty'),
(7, 'Lechuga'),
(8, 'Tomate')

insert into Proveedor values
(1, 'Panadería Carlitos', 'Carlos Calvo 1212', 'CABA'),
(2, 'Fiambres Perez', 'San Martin 121', 'Pergamino'),
(3, 'Almacen San Pedrito', 'San Pedrito 1244', 'CABA'),
(4, 'Carnicería Boedo', 'Av. Boedo 3232', 'CABA'),
(5, 'Verdulería Platense', '5 3232', 'La Plata')

insert into Tiene values
--Juan Perez
(1, 1),

--Jose Basualdo
(2, 1),
(2, 2),
(2, 3),
(2, 4),

--Rogelio Rodriguez
(3, 3),
(3, 4)

insert into Compuesto_Por values
--Sandwich JyQ
(1, 1), (1, 2), (1, 3),

--Pancho
(2, 4), (2, 5),

--Hamburguesa
(3, 1), (3, 6),

--Hamburguesa completa
(4, 1), (4, 6), (4, 7), (4, 8)

insert into Provisto_Por values
--Pan
(1, 1), (1, 3),

--Jamon
(2, 2), (2, 3), (2, 4),

--Queso
(3, 2), (3, 3),

--Salchicha
(4, 3), (4, 4),

--Pan Pancho
(5, 1), (5, 3),

--Paty
(6, 3), (6, 4),

--Lechuga
(7, 3), (7, 5),

--Tomate
(8, 3), (8, 5)

-----------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Listar los nombres de los proveedores de la ciudad de La Plata.

SELECT Nombre
FROM Proveedor
WHERE Ciudad = 'La plata'

-- 2. Listar los números de artículos cuyo precio sea inferior a $10.

SELECT CodArt
FROM Articulo
WHERE Precio < 10

-- 3. Listar los responsables de los almacenes.

SELECT Responsable
FROM Almacen

-- 4. Listar los códigos de los materiales que provea el proveedor 3 y no los provea el proveedor 5.

SELECT CodMat
FROM Provisto_por
WHERE CodProv = 3 and CodMat NOT IN ( SELECT CodMat
										FROM Provisto_por
										WHERE CodProv = 5)

SELECT CodMat
FROM Provisto_por
WHERE CodProv = 3 
EXCEPT
SELECT CodMat
FROM Provisto_por
WHERE CodProv = 5

-- 5. Listar los números de almacenes que almacenan el artículo 1.

SELECT Nro
FROM Tiene
WHERE CodArt = 2

SELECT	t.*
FROM	Tiene t, Articulo a
WHERE	t.CodArt = a.CodArt
AND		a.Descripcion = 'Pancho'

-- 6. Listar los proveedores de Pergamino que se llamen Pérez.

SELECT  *
FROM Proveedor
WHERE Nombre LIKE '%Perez%' AND Ciudad = 'Pergamino'

-- 7. Listar los almacenes que contienen los artículos A y los artículos B (ambos).

SELECT Nro
FROM Tiene
WHERE CodArt = 1 AND Nro IN (SELECT Nro
								FROM Tiene
								WHERE CodArt = 2)


SELECT	t.*
FROM	Tiene t, Articulo a
WHERE	t.CodArt = a.CodArt
AND		a.Descripcion = 'Pancho'
INTERSECT
SELECT	t.*
FROM	Tiene t, Articulo a
WHERE	t.CodArt = a.CodArt
AND		a.Descripcion = 'Hamburguesa completa'




-- 8. Listar los artículos que cuesten más de $100 o que estén compuestos por el material M1

SELECT a.CodArt, a.Descripcion
FROM Articulo a 
INNER JOIN Compuesto_por c ON a.CodArt = c.CodArt
WHERE a.precio > 8 and c.CodMat = 1

SELECT CodArt
FROM Articulo
WHERE Precio > 8
UNION
SELECT c.CodArt
FROM Compuesto_por c, Material m
WHERE c.CodMat = m.codMat
AND m.Descripcion = 'Lechuga'

-- 9. Listar los materiales, código y descripción, provistos por proveedores de la ciudad de CABA.

SELECT m.CodMat, m.Descripcion
FROM Material m
INNER JOIN Provisto_por p ON m.CodMat = p.CodMat
INNER JOIN Proveedor prov ON p.CodProv = prov.CodProv
WHERE prov.Ciudad = 'Pergamino'
GROUP BY m.CodMat, m.Descripcion

SELECT m.CodMat, m.Descripcion
FROM Material m
WHERE m.CodMat IN (SELECT p.CodMat
					FROM Provisto_por p
					WHERE p.CodMat = m.CodMat and p.CodProv IN (SELECT prov.CodProv
																	FROM Proveedor prov
																	WHERE prov.Ciudad = 'Pergamino'))

-- 10. Listar el código, descripción y precio de los artículos que se almacenan en A1

SELECT a.CodArt, a.Descripcion, a.Precio
FROM Articulo a
INNER JOIN Tiene t ON a.CodArt = t.CodArt
WHERE t.Nro = 1

-- 11. Listar la descripción de los materiales que componen el artículo B.

SELECT m.descripcion
FROM Material m
INNER JOIN Compuesto_por c ON m.CodMat = c.CodMat
WHERE c.CodArt = 1

-- 12. Listar los nombres de los proveedores que proveen los materiales al almacén que Martín Gómez tiene a su cargo.

SELECT p.Nombre
FROM Proveedor p
INNER JOIN Provisto_por pp ON pp.CodProv = p.CodProv
INNER JOIN Material m ON pp.CodMat = m.CodMat
INNER JOIN Compuesto_por cp ON m.CodMat = cp.CodMat
INNER JOIN Articulo a ON cp.CodArt = a.CodArt
INNER JOIN Tiene t ON a.CodArt = t.CodArt
INNER JOIN Almacen alm ON t.Nro = alm.Nro
Where alm.Responsable = 'Jose Basualdo'

SELECT a.Nro, q.Nombre
FROM Almacen a 
INNER JOIN Tiene t ON a.Nro = t.Nro
INNER JOIN Compuesto_por c ON t.CodArt = c.CodArt
INNER JOIN Provisto_por p ON c.CodMat = p.CodMat
INNER JOIN Proveedor q ON p.CodProv = q.CodProv
WHERE a.Responsable = 'Jose Basualdo'


SELECT a.Nro, q.Nombre
FROM Almacen a, Tiene t, Compuesto_por c, Provisto_por p, Proveedor q
WHERE a.Responsable = 'Jose Basualdo'
AND a.Nro = t.Nro
AND t.CodArt = c.CodArt
AND c.CodMat = p.CodMat
AND p.CodProv = q.CodProv

-- 13. Listar códigos y descripciones de los artículos compuestos por al menos un material provisto por el proveedor López.

SELECT distinct a.CodArt, a.Descripcion
FROM Articulo a
INNER JOIN Compuesto_por cp ON a.CodArt = cp.CodArt
INNER JOIN Provisto_por pp ON cp.CodMat = pp.CodMat
INNER JOIN Proveedor p ON pp.CodProv = p.CodProv
WHERE p.Nombre LIKE '%verdu%'


-- 14. Hallar los códigos y nombres de los proveedores que proveen al menos un material que se usa en algún artículo cuyo precio es mayor a $100.

SELECT distinct p.CodProv, p.Nombre
FROM Proveedor p
INNER JOIN Provisto_por pp ON p.CodProv = pp.CodProv
INNER JOIN Compuesto_por cp ON pp.CodMat = cp.CodMat
INNER JOIN Articulo a ON cp.CodArt = a.CodArt
WHERE a.Precio < 6


-- 15. Listar los números de almacenes que tienen todos los artículos que incluyen el material con código 123.

	--> Articulos compuestos por mat 6
SELECT *
FROM Compuesto_por
WHERE CodMat = 6
	--> Almacenes que tienen a TODOS los articulos compuestos por el material 6

	--> Almacenes tales que NO EXISTE un articulo compuesto por el material 6 que NO tengan

SELECT *
FROM Almacen a
WHERE NOT EXISTS (SELECT *
					FROM Compuesto_por c
					WHERE CodMat = 6
					AND NOT EXISTS (SELECT *
									FROM Tiene t
									WHERE t.CodArt = c.CodArt
									AND T.Nro = a.Nro))



-- 16. Listar los proveedores de Capital Federal que sean únicos proveedores de algún material.

SELECT *
FROM Proveedor p, Provisto_por x
WHERE p.Ciudad = 'CABA'
AND p.CodProv = x.CodProv
AND NOT EXISTS ( SELECT *
					FROM Provisto_por x2, Proveedor p2
					WHERE x2.CodMat = x.CodMat
					AND	x2.CodProv <> x.CodProv
					AND x2.CodProv = p2.CodProv
					AND P2.Ciudad = 'CABA')


-- 17. Listar el/los artículo/s de mayor precio.

SELECT *
FROM ARTICULO
WHERE precio = (SELECT MAX(Precio)
				FROM Articulo)

SELECT *
FROM Articulo
WHERE Precio >= ALL (SELECT Precio
						FROM Articulo)


-- 18. Listar el/los artículo/s de menor precio.

SELECT *
FROM Articulo
WHERE Precio = (SELECT min(precio)
				FROM Articulo)


-- 19. Listar el promedio de precios de los artículos en cada almacén.

SELECT Nro, AVG(Precio) PRECIO_PROMEDIO
FROM Tiene t, Articulo a
WHERE t.CodArt = a.CodArt
GROUP BY t.Nro


-- 20. Listar los almacenes que almacenan la mayor cantidad de artículos

CREATE VIEW Cant_Articulos AS
SELECT Nro, count(*) CANT_ART
FROM Tiene
GROUP BY Nro

SELECT *
FROM Cant_Articulos
WHERE CANT_ART = (SELECT MAX(CANT_ART)
					FROM Cant_Articulos)


-- 21. Listar los artículos compuestos por al menos 2 materiales.

SELECT	cp.CodArt, a.Descripcion, count(*) CANT_MATERIALES
FROM	Compuesto_por cp
INNER JOIN Articulo a ON cp.CodArt = a.CodArt
GROUP BY cp.CodArt, a.Descripcion
HAVING count(*) >= 2


-- 22. Listar los artículos compuestos por exactamente 2 materiales

SELECT CodArt, count(*) CANT_MATERIALES
FROM Compuesto_por
GROUP BY CodArt
HAVING count(*) = 2


-- 23. Listar los artículos que estén compuestos con hasta 2 materiales

SELECT CodArt, count(*) CANT_MATERIALES
FROM Compuesto_por
GROUP BY CodArt
HAVING count(*) <= 2


-- 24. Listar los artículos compuestos por todos los materiales.

SELECT *
FROM Articulo a
WHERE NOT EXISTS (SELECT *
					FROM Material m
					WHERE NOT EXISTS ( SELECT *
										FROM Compuesto_por cp
										WHERE cp.CodArt = a.CodArt
										AND cp.CodMat = m.CodMat))

SELECT *
FROM Articulo
WHERE EXISTS ( SELECT CodArt
					FROM Compuesto_por)

					



-- 25. Listar las ciudades donde existan proveedores que provean todos los materiales.

SELECT p.Ciudad
FROM Proveedor p
WHERE NOT EXISTS (SELECT *
					FROM Compuesto_por cp
					WHERE NOT EXISTS ( SELECT *
										FROM Provisto_por pp
										WHERE pp.CodProv = p.CodProv
										AND		cp.CodMat = pp.CodMat))


DROP TABLE Tiene
DROP TABLE Compuesto_por
DROP TABLE Provisto_por
DROP TABLE Almacen
DROP TABLE Articulo
DROP TABLE Material
DROP TABLE Proveedor

