USE UnlamBD

CREATE TABLE Departamento
(
cod_depto integer PRIMARY KEY,
descripcion varchar(30),
)


CREATE TABLE Empleado
(
legajo integer PRIMARY KEY,
nombre varchar(30),
salario numeric(8,2),
categoria char(1),
cod_depto integer FOREIGN KEY REFERENCES Departamento (cod_depto),
)

CREATE TABLE Empresa
(
legajo integer PRIMARY KEY,
nombre varchar(30),
cod_depto integer,
)

INSERT INTO Empresa values (1, 'Dani', 1)
INSERT INTO Empresa values (2, 'Guille', 2)
INSERT INTO Empresa values (3, 'Ale', 2)

INSERT INTO Departamento VALUES (1,'Ventas')
INSERT INTO Departamento VALUES (2,'Compras')
INSERT INTO Departamento VALUES (3,'Administracion')
INSERT INTO Departamento VALUES (4,'Marketing')
INSERT INTO Departamento VALUES (5,'Sistemas')
INSERT INTO Empleado VALUES (100,'Marcelo',120000,'B',1)
INSERT INTO Empleado VALUES (101,'Diego',60000,'A',2)
INSERT INTO Empleado VALUES (102,'Andrea',90000,'C',3)
INSERT INTO Empleado VALUES (103,'Janice',100000,'C',4)
INSERT INTO Empleado VALUES (104,'Duilio',110000,'A',null)
INSERT INTO Empleado VALUES (105,'Ezequiel',160000,'B',5)
INSERT INTO Empleado VALUES (106,'Mariano',180000,'B',5)
INSERT INTO Empleado VALUES (107,'Sebastian',150000,'C',5)


DROP TABLE Empleado
DROP TABLE Departamento
DROP TABLE Empresa

