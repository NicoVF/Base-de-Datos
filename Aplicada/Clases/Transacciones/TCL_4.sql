
------------------------------ Ejemplo 3 READ COMMITTED
/*Especifica que las instrucciones no pueden leer datos que hayan sido modificados, pero no confirmados, por otras transacciones.  
Esta opci�n es la predeterminada para SQL Server*/

--Veamos el ejemplo anterior con este nivel de aislamiento

--Actualizacion del limite de credito desde el banco 

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
		BEGIN TRANSACTION; 
		DECLARE
		@credit_card_nro bigint,
		@credit_card_lim int
		SET @credit_card_nro = 1280981422329509
		SET @credit_card_lim = 9000
			/* Actualizamos el limite de credito */
 
				/* Actualizamos el limite de credito */
				UPDATE creditCard_info 
				SET credit_card_limit = credit_card_limit + @credit_card_lim 
				WHERE credit_card_nro = @credit_card_nro
		--5 Ejecutar hasta Aqui!!
		--6 ejecutar la consulta de Limite de credito
		--7 Monto del limite: <completar> Guardar TCL4
		--8 Volver a TCL1
		--11 Seleccionar el COMMIT TRANSACTION y presionar Execute.
		--12 Volver a TCL1
		/* Confirmamos la transaccion*/
		COMMIT TRANSACTION			 
		--Veamos que sucedi� a nivel tabla 1280981422329509
		
		--confirmar si se actualiz� el limite de credito
		Select * 
		from dbo.creditCard_info 
		Where credit_card_nro = 1280981422329509
		--Monto del limite: <completar> --