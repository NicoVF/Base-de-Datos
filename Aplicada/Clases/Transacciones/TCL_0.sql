
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

----------------------------- Transacciones explicitas

--Chequear  la configuración actual de IMPLICIT_TRANSACTIONS
DECLARE @IMPLICIT_TRANSACTIONS VARCHAR(3) = 'OFF';  
IF ((2 & @@OPTIONS) = 2 ) 
	SET @IMPLICIT_TRANSACTIONS = 'ON';  
SELECT @IMPLICIT_TRANSACTIONS AS ModoImplicitTranActual; 

-- IMPLICIT_TRANSACTIONS debe encontrarse en OFF

--Para activar Modo implícito:  SET IMPLICIT_TRANSACTIONS ON
--Para desactivar Modo implícito:  SET IMPLICIT_TRANSACTIONS OFF

------------- ejemplo
/*
Cada transacción se inicia explícitamente con la instrucción BEGIN TRANSACTION 
y se termina explícitamente con una instrucción COMMIT o ROLLBACK.
*/
--Escenario: Un cliente realiza la compra con tarjeta de credito. 
--Al registrarse la venta se descuenta el limite de credito disponible
--La operación se realiza en un pago o en una cuota.

BEGIN TRANSACTION;
		DECLARE 
		@id_transaction int,
		@transaction_amount float,
		@credit_card_nro bigint,
		@date datetime,
		@transaction_type char,
		@credit_card_limit_1 bigint

		/* Asignamos el monto de la transacción */
		SET @id_transaction = 1001
		SET @credit_card_nro = '1280981422329509'
		SET @date =GETDATE() 
		SET @transaction_amount = 100
		SET @transaction_type= 'V'

		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro

		if (@credit_card_limit_1 > @transaction_amount) 
			BEGIN 
				   /* Registramos la venta*/
					Insert into dbo.Transaccion
					Values  (@id_transaction,@credit_card_nro,@date,@transaction_amount,null,@transaction_type)

					/* Actualizamos el limite de credito */
					UPDATE dbo.creditCard_info 
					SET credit_card_limit = credit_card_limit - @transaction_amount
					WHERE credit_card_nro = @credit_card_nro
			END
        ELSE
			BEGIN
				PRINT 'No se puede realizar la compra.  Excede limite de credito disponible';
			END;
		COMMIT TRANSACTION; 


--Veamos que sucedió a nivel tabla 1280981422329509
--confirmar si se actualizó el limite de credito
Select * 
from dbo.Transaccion
where credit_card_nro = 1280981422329509
-- V - 1000
Select * 
from dbo.creditCard_info 
Where credit_card = 1280981422329509

--Al no haber otra transacción involucrada no hay conflictos ni en la lectura ni en la escritura.
--Cerrar el archivo.