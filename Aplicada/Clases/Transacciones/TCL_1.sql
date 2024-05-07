
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

---------------------------------------- Ejemplo 2 READ UNCOMMITTED -READ COMMITTED
/*
READ UNCOMMITTED 
Especifica que las instrucciones pueden leer filas que han sido modificadas por otras transacciones, 
pero todavía no se han confirmado.  Se trata del nivel de aislamiento menos restrictivo
*/
--Escenario: El cliente de un banco solicita que se le actualice el LC para poder realizar una compra 
--Ejecutar --> Abrir otra instancia de SQL Server, conectarse a la base de datos y abrir el archivo TCL_4.sql

--1 Ejecutar la transaccion de forma completa - Que se obtiene como resultado?
--2 Consultar el valor del limite de credito
--3 Monto del limite: <completar>
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- Especifica que las instrucciones pueden leer filas que han sido modificadas por otras transacciones, pero todavía no se han confirmado
		BEGIN TRANSACTION;
		DECLARE
		@id_transaction_1 int,
		@transaction_amount_1 float,
		@credit_card_nro_1 bigint,
		@date_1 datetime,
		@transaction_type_1 char,
		@credit_card_limit_1 bigint
		
		--Seteo de variables
		SET @credit_card_nro_1 = 1280981422329509
		SET @id_transaction_1 = 10004
		SET @date_1 =GETDATE() 
		SET @transaction_amount_1 = 500
		SET @transaction_type_1= 'V'


		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro_1

		--04 IR a TCL2
		--09 Ejecutar la consulta de limite de credito 
		--10 Ejecutar la transacción completa -Que se obtiene como resultado?
		--11 Monto del limite: <completar> 

		if (@credit_card_limit_1 > @transaction_amount_1) 
		BEGIN 
		   /* Registramos la venta*/
			Insert into dbo.Transaccion
			Values  (@id_transaction_1,@credit_card_nro_1,@date_1,@transaction_amount_1,null,@transaction_type_1)

			/* Actualizamos el limite de credito */
			UPDATE dbo.creditCard_info 
			SET credit_card_limit = credit_card_limit - @transaction_amount_1 
			WHERE credit_card_nro = @credit_card_nro_1
		END
        ELSE
			BEGIN
				PRINT 'No se puede realizar la compra.  Excede limite de credito disponible';
			END;
		COMMIT TRANSACTION; 




