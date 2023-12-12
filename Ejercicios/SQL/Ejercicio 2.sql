USE UnlamBD

create table Proveedor
(
NroProv int primary key, 
NomProv varchar(50), 
Categoria int,
CiudadProv varchar(50)
)


create table Articulo
(
NroArt int primary key, 
Descripcion varchar(50), 
CiudadArt varchar(50),
Precio decimal(12,3)
)


create table Cliente
(
NroCli int primary key, 
NomCli varchar(50),
CiudadCli varchar(50)
)


create table Pedido
(
NroPed int primary key, 
NroArt int,
NroCli int,
NroProv int,
FechaPedido date,
Cantidad int,
PrecioTotal decimal(8,2),
FOREIGN KEY (NroArt) REFERENCES Articulo (NroArt),
FOREIGN KEY (NroCli) REFERENCES Cliente (NroCli),
FOREIGN KEY (NroProv) REFERENCES Proveedor (NroProv)
)


create table Stock
(
NroArt int, 
fecha int,
cantidad int,
PRIMARY KEY(NroArt, fecha),
FOREIGN KEY (NroArt) REFERENCES Articulo (NroArt)
)


insert into Proveedor values
(1, 'Panadería Carlitos', 1, 'CABA'),
(2, 'Fiambres Perez', 2, 'Pergamino'),
(3, 'Almacen San Pedrito', 3, 'CABA'),
(4, 'Carnicería Boedo', 2, 'CABA'),
(5, 'Verdulería Platense', 2, 'La Plata')



insert into Articulo values
(1, 'Sandwich JyQ', 'CABA', 5),
(2, 'Pancho', 'Bahia Blanca', 6),
(3, 'Hamburguesa', 'MDQ', 10),
(4, 'Hamburguesa completa', 'Pinamar', 15)


insert into Cliente values
(1, 'Juan Perez', 'CABA'),
(2, 'Jose Basualdo', 'Ramos Mejia'),
(3, 'Rogelio Rodriguez', 'Ciudadela')


insert into Pedido values
(1,2,1,2,'22-11-11 11:12:01 AM', 1,10),
(2,2,3,3,'22-10-11 11:12:02 AM', 3,15),
(3,1,1,1,'22-9-11 11:12:03 AM', 8,19),
(4,4,1,2,'22-8-11 11:12:04 AM', 2,14),
(5,3,3,1,'22-7-11 11:12:05 AM', 12,22)


insert into Stock values
(1,'22-11-11', 1),
(2,'22-10-11', 3),
(3,'22-9-11', 8),
(4,'22-8-11', 2)


-- 1. Hallar el código (nroProv) de los proveedores que proveen el artículo a146.

SELECT pr.NroProv
FROM Proveedor pr
INNER JOIN Pedido pe ON pr.NroProv = pe.NroProv
WHERE pe.NroArt = 2

-- 2. Hallar los clientes (nomCli) que solicitan artículos provistos por p015.

SELECT c.NomCli
FROM Cliente c
INNER JOIN Pedido pe ON c.NroCli = pe.NroCli
WHERE pe.NroProv = 3

-- 3. Hallar los clientes que solicitan algún item provisto por proveedores con categoría mayor que 4.

SELECT c.NomCli
FROM Cliente c
INNER JOIN Pedido pe ON c.NroCli = pe.NroCli
INNER JOIN Proveedor prov ON pe.NroProv = prov.NroProv
WHERE prov.Categoria > 2


-- 4. Hallar los pedidos en los que un cliente de Rosario solicita artículos producidos en la ciudad de Mendoza

SELECT p.FechaPedido, p.NroArt, p.NroCli
FROM Pedido p
INNER JOIN Cliente c ON p.NroCli = c.NroCli
INNER JOIN Articulo a ON p.NroArt = a.NroArt
WHERE c.CiudadCli = 'Ciudadela' AND a.CiudadArt = 'Bahia Blanca'


-- 5. Hallar los pedidos en los que el cliente c23 solicita artículos solicitados por el cliente c30.

SELECT *
FROM Pedido p1, Pedido p2
WHERE p1.NroCli = 1
AND p2.NroCli = 3
AND p1.NroArt = p2.NroArt

SELECT *
FROM Pedido p1
WHERE p1.NroCli = 3 

SELECT *
FROM Pedido p2
WHERE p2.NroCli = 1





DROP TABLE Pedido
DROP TABLE Articulo
DROP TABLE Cliente
DROP TABLE Proveedor
DROP TABLE Stock
