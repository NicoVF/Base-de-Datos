-- READ UNCOMMITTED

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION

SELECT count(*)
FROM Empresa
WHERE cod_depto=2

SELECT count(*)
FROM Empresa
WHERE cod_depto=2;

COMMIT TRANSACTION

/*En este caso se produce una Lectura suciaen la segunda consulta de T1, ya que velos cambios hechos por otras transacciones antes de quelos mismos sean confirmados.*/

-- Caso 2-READ COMMITTED(por defecto)

SET TRANSACTION ISOLATION 
LEVEL REPEATABLE READ

BEGIN TRANSACTION

SELECT count(*)
FROM Empresa
WHERE cod_depto=2

SELECT count(*)
FROM Empresa
WHERE cod_depto=2;

COMMIT TRANSACTION


SET TRANSACTION ISOLATION 
LEVEL SERIALIZABLE

BEGIN TRANSACTION

SELECT count(*)
FROM Empresa
WHERE cod_depto=2

SELECT count(*)
FROM Empresa
WHERE cod_depto=2;

COMMIT TRANSACTION