-- Sebastian Alvarez (257209)
-- Andres Mayes (230729)
-- Juan Martinez (275957)

	USE ViveroPflanzeObligatorio;
	SET DATEFORMAT dmy

------------------------------------------------------------------------------------
-- PROCEDURE Y FUNCTION
------------------------------------------------------------------------------------
-- 3.A

-- Implementar un procedimiento AumentarCostosPlanta que reciba por parámetro: un Id de
-- Planta, un porcentaje y un rango de fechas. El procedimiento debe aumentar en el
-- porcentaje dado, para esa planta, los costos de mantenimiento que se dieron en ese rango
-- de fechas. Esto tanto para mantenimientos de tipo “OPERATIVO” donde se aumenta el
-- costo por concepto de mano de obra (no se aumentan las horas, solo el costo) como de
-- tipo “NUTRIENTES” donde se debe aumentar los costos por concepto de uso de producto
-- (no se debe aumentar ni los gramos de producto usado ni actualizar nada del maestro de
-- productos)
-- El procedimiento debe retornar cuanto fue el aumento total de costo en dólares para la
-- planta en cuestión.

	CREATE PROCEDURE AumentarCostosPlanta @IdPlanta int, @porcentaje int, @f1 DateTime, @f2 DateTime, @aumentoTotal decimal(6,2) OUT AS
	BEGIN
		DECLARE @idMantenimientoW INT = 1;
		DECLARE @largoMantenimientos INT = (SELECT MAX(IdMantenimiento) FROM Mantenimiento);
		SET @aumentoTotal = 0.00;

		WHILE @idMantenimientoW <= @largoMantenimientos
		BEGIN -- BEGIN WHILE
			IF (SELECT FechaHora 
				FROM Mantenimiento 
				WHERE	@idMantenimientoW = IdMantenimiento) > @f1 
			AND
				(SELECT FechaHora 
				FROM Mantenimiento 
				WHERE @idMantenimientoW = IdMantenimiento) < @f2 
			AND	
				(SELECT IdPlanta
				FROM Mantiene 
				WHERE @idMantenimientoW = IdMantenimiento) = @IdPlanta
			BEGIN -- BEGIN IF CONTROL FECHAS Y IDPLANTA
				IF @idMantenimientoW IN (SELECT IdMantenimiento FROM Operativo)	
				BEGIN -- BEGIN IF OPERATIVO
					DECLARE @costoInicialOp DECIMAL(5,2) = (SELECT Costo FROM Operativo WHERE IdMantenimiento = @idMantenimientoW)
				
					UPDATE Operativo
					SET Costo *= (1.00 + (@porcentaje/100.00))
					WHERE IdMantenimiento = @idMantenimientoW

					SET @aumentoTotal += (SELECT Costo FROM Operativo WHERE IdMantenimiento = @idMantenimientoW) - @costoInicialOp;
				END -- FIN IF OPERATIVO
				ELSE IF @idMantenimientoW IN (SELECT IdMantenimiento FROM Nutrientes)	
				BEGIN -- BEGIN ELSE NUTRIENTES
					DECLARE @costoInicialNutri DECIMAL(6,2) = (SELECT SUM(CostoAplicacion) FROM Nutrientes WHERE IdMantenimiento = @idMantenimientoW)

					UPDATE Nutrientes
					SET CostoAplicacion *= (1.00 + (@porcentaje / 100.00))
					WHERE IdMantenimiento = @idMantenimientoW
					
					SET @aumentoTotal += (SELECT SUM(CostoAplicacion) FROM Nutrientes WHERE IdMantenimiento = @idMantenimientoW) - @costoInicialNutri;
				END -- FIN ELSE NUTRIENTES

			END --CONTROL FECHAS Y IDPLANTA
		
			SET @idMantenimientoW = @idMantenimientoW + 1;
		END -- END WHILE
	END -- END PROCEDURE


	SET DATEFORMAT dmy
	DECLARE @total decimal(7,2);
	EXEC AumentarCostosPlanta 4, 20, '4/12/2010', '4/12/2022', @total OUT
	PRINT @total;

--3.B

-- Mediante una función que recibe como parámetro un año: retornar el costo promedio de
-- los mantenimientos de tipo “OPERATIVO” de ese año
	CREATE FUNCTION PromedioCostoMantenimientosOperativosAnio (@anio INT) RETURNS DECIMAL(6,2) AS
	BEGIN
		RETURN	(SELECT SUM(Costo)/COUNT(*)
				FROM Mantenimiento m, Operativo o
				WHERE	m.IdMantenimiento = o.IdMantenimiento
				AND		YEAR(FechaHora) = @anio)
	END

	SELECT dbo.PromedioCostoMantenimientosOperativosAnio(2020) AS Promedio