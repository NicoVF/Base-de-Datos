USE DATABASE UnlamBD

CREATE TABLE Persona 

( 
DNI       numeric(8,0) PRIMARY KEY, 
Nombre    varchar(30), 
Direccion varchar(80), 
FechaNac  date, 
Sexo      char(1), 
) 

 

CREATE TABLE Progenitor 

( 
DNI       numeric(8,0), 
DNI_Hijo  numeric(8,0), 
PRIMARY KEY (DNI, DNI_Hijo), 
FOREIGN KEY (DNI) REFERENCES Persona(DNI), 
FOREIGN KEY (DNI_Hijo) REFERENCES Persona(DNI), 
) 


INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (10100100,'Hector','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (10100200,'Maria','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (10200100,'Francisco','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (10200200,'Juana','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (20100100,'Jorge','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (20100200,'Claudio','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (20100300,'Susana','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (20200100,'Oscar','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (20200200,'Alicia','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (30100100,'Diego','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (30100200,'Natalia','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (30200100,'Pablo','M'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (30200200,'Laura','F'); 
INSERT INTO Persona (DNI,NOMBRE,SEXO) VALUES (30200300,'Sabrina','F'); 


INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100100,20100100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100100,20100200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100100,20100300); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100200,20100100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100200,20100200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10100200,20100300); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10200100,20200100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10200100,20200200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10200200,20200100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (10200200,20200200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20100100,30100100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20100100,30100200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20200200,30100100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20200200,30100200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20100300,30200100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20100300,30200200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20100300,30200300); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20200100,30200100); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20200100,30200200); 
INSERT INTO Progenitor (DNI,DNI_HIJO) VALUES (20200100,30200300); 


-- 1. Hallar para una persona dada, por ejemplo José Pérez, los tipos y números de documentos, nombres, dirección y fecha de nacimiento de todos sus hijos.

SELECT	distinct hijo.*, hijo2.*
FROM	Persona padre, Progenitor p, Persona hijo, Progenitor p2, Persona hijo2
WHERE	padre.dni = p.dni
AND		p.dni_hijo = hijo.dni
AND		padre.dni = p2.dni
AND		p2.dni_hijo = hijo2.dni
AND		hijo.dni <> hijo2.dni
Order By 1

-- 2. Hallar para cada persona los tipos y números de documento, nombre, domicilio y  fecha de nacimiento de:
/*
a. Todos sus hermanos, incluyendo medios hermanos.
b. Su madre
c. Su abuelo materno
d. Todos sus nietos
*/

-- b

SELECT	per.dni, per.nombre,
		mad.dni DNI_MADRE, mad.nombre NOMBRE_MADRE
FROM	Persona per, Progenitor pro, Persona mad
WHERE	pro.DNI_Hijo = per.DNI
AND		pro.DNI = mad.DNI
AND		mad.Sexo = 'F'

-- c

SELECT	per.dni, per.nombre,
		abu_mat.dni DNI_ABU_MAT, abu_mat.nombre NOMBRE_ABU_MAT
FROM	Persona per, Progenitor pro, Persona mad, Progenitor pro2, Persona abu_mat
WHERE	pro.DNI_Hijo = per.DNI
AND		pro.DNI = mad.DNI
AND		mad.Sexo = 'F'
AND     pro2.DNI = abu_mat.dni
AND		pro2.DNI_Hijo = mad.DNI
AND		abu_mat.Sexo = 'M'

-- d

SELECT	per.dni, per.nombre,
		nie.dni DNI_NIETO, nie.nombre NOMBRE_NIETO
FROM	Persona per, Progenitor pro1, Progenitor pro2, Persona nie
WHERE	pro1.DNI = per.DNI
AND		pro2.dni = pro1.DNI_Hijo
AND     pro2.DNI_hijo = nie.dni


DROP TABLE Persona
DROP TABLE Progenitor