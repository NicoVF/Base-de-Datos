USE UnlamBD

-- SIN BLOQUEO

BEGIN TRANSACTION;

SELECT *
FROM Empleado


UPDATE Emplado
SET salario = salaio * 1.2


COMMIT


-- BLOQUEA TABLA EMPLEADO

-- T1 lee la tabla Empleado, luego modifica el salario de todos los empleados (les aumenta un 20%) y luego T2 intenta leer la tabla Empleado y se queda esperando a que T1 haga commit o rollback.

BEGIN TRANSACTION

SELECT *
FROM Empleado

UPDATE Empleado
SET salario = salario * 1.2

COMMIT

-- BLOQUEO A NIVEL FILA
/* Caso 3: T1 bloquea una fila de la tabla Empleado y T2 puede modificar otra fila

Cuando se coloca una condicion por la Primary Key de la tabla, entonces el bloqueo es por fila, y de esa forma permite que dos transacciones puedan hacer cambios en la misma tabla en forma simultanea, en distintas filas. Pero es impresindible que se coloque en el WHERE una condicion sobre la clave de la tabla.
*/

BEGIN TRANSACTION

SELECT *
FROM Empleado

UPDATE Empleado 
SET salario = salario * 2
WHERE legajo = 100

COMMIT

-- SE BLOQUEA AL NO ESTAR LA CONDICION EN PK
/*Caso 4: T1 bloquea un subconjunto de filas y T2 no puede modificar otras filas

En este caso, T1 modifica el salario de los Empleados de categoria A y luego T2 quiere modificar el salario de los empleados de categoria B, pero no puede hacerlo porque la tabla está bloqueada.

Solo permite que dos transacciones hagan cambios en distintas filas de la misma tabla cuando se indica una condicion sobre la Clave Primaria de la tabla.
*/

BEGIN TRANSACTION

SELECT *
FROM Empleado

Update Empleado
SET salario = salario * 2
WHERE categoria = 'A'

COMMIT

/*Caso 5: Deadlock

T1 modifica la tabla Empleado y T2 modifica la tabla Departamento. Luego, T1 quiere leer la tabla Departamento pero no puede porque está bloqueada por T2 entonces se queda esperando y T2 quiere leer la tabla Empleado y tambien se queda esperando porque está bloqueada. Ambas transacciones se quedan esperando mutuamente, en forma infinita.

Esto se llama Deadlock o Abrazo mortal. Cuando esto sucede, el motor de Base de Datos elije a una de las dos transacciones en forma aleatoria y la “mata” para que libere los recursos y la otra pueda continuar.
*/

BEGIN TRANSACTION

SELECT *
FROM Empleado

UPDATE Empleado
SET salario = salario - 10000

SELECT *
FROM Departamento

COMMIT