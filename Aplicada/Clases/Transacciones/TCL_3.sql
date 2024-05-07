
------------------------------ Ejemplo 3 READ COMMITTED
/*Especifica que las instrucciones no pueden leer datos que hayan sido modificados, pero no confirmados, por otras transacciones.  
Esta opción es la predeterminada para SQL Server*/

--Veamos el ejemplo anterior con este nivel de aislamiento


--Escenario: El cliente de un banco solicita que se le actualice el LC para poder realizar una compra 
--Ejecutar --> Abrir otra instancia de SQL Server, conectarse a la base de datos y abrir el archivo TCL_4.sql
--
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
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
		SET @id_transaction_1 = 10002
		SET @date_1 =GETDATE() 
		SET @transaction_amount_1 = 52000 
		SET @transaction_type_1= 'V'


		-- Consulta de limite del usuario.
		Select @credit_card_limit_1= credit_card_limit
		from creditCard_info
		where credit_card_nro =@credit_card_nro

		--1 Ejecutar hasta Aqui!! sin haber hecho el commit de TCL4.
		--2 Consultar el valor del limite de credito: que sucede ?
		--3 Monto del limite: <completar>
		--4 IR a TCL4
		--9 Ejecutar la transacción completa de este script. que sucede?
		--10 IR a TCL4
		--13 Ejecutar la transacción completa de este script. que sucede?

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

		--Consulta de limite del usuario 
		Select * 
		from dbo.creditCard_info
		where credit_card_nro = 1280981422329509
		--Monto del limite: <completar> 