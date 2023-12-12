-- READ UNCOMMITTED

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRANSACTION

UPDATE Empresa
SET cod_depto = 1 
WHERE nombre = 'Ale'

COMMIT TRANSACTION;


/*En este caso se produce una Lectura suciaen la segunda consulta de T1, ya que velos cambios hechos por otras transacciones antes de quelos mismos sean confirmados.*/

-- -- Caso 2-READ COMMITTED(por defecto)

SET TRANSACTION ISOLATION 
LEVEL REPEATABLE READ

BEGIN TRANSACTION

UPDATE Empresa
SET cod_depto = 1 
WHERE nombre = 'Ale'

COMMIT TRANSACTION;




SET TRANSACTION ISOLATION 
LEVEL SERIALIZABLE

BEGIN TRANSACTION

INSERT INTO Empresa VALUES (4, 'Pepe', 1)

COMMIT TRANSACTION;
