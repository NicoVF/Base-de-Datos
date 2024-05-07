USE TCL
GO

-- Veamos las tablas con las que vamos a trabajar
Select * 
from dbo.Transaccion
/* Copiar el contenido de la tabla

*/

Select * 
from dbo.creditCard_info 
/* Copiar el contenido de la tabla

*/

------------------------------ Ejemplo 2 READ UNCOMMITTED -READ COMMITTED
/*READ COMMITTED
Especifica que las instrucciones no pueden leer datos que hayan sido modificados, pero no confirmados, por otras transacciones.  
Esta opción es la predeterminada para SQL Server.
*/
--Actualizacion del limite de credito desde el banco  (TCL2)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
		BEGIN TRANSACTION; 
		DECLARE
		@credit_card_nro bigint,
		@credit_card_lim int
		SET @credit_card_nro = 1280981422329509
		SET @credit_card_lim = 10000
			/* Actualizamos el limite de credito */
 
				/* Actualizamos el limite de credito */
				UPDATE creditCard_info 
				SET credit_card_limit = credit_card_limit+@credit_card_lim 
				WHERE credit_card_nro = @credit_card_nro
		--5 Ejecutar hasta Aqui!!
		--6 ejecutar la consulta de Limite de credito
		--7 Monto del limite: <completar> Guardar 
		--8 Volver a TCL1

		/* Confirmamos la transaccion*/
		COMMIT TRANSACTION			 


