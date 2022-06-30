-- Sebastian Alvarez (257209)
-- Andres Mayes (230729)
-- Juan Martinez (275957)

	USE ViveroPflanzeObligatorio;
	SET DATEFORMAT dmy

------------------------------------------------------------------------------------------------------------
-- TRIGGERS
------------------------------------------------------------------------------------------------------------


-- 4. Mediante el uso de disparadores, crear las siguientes reglas de negocio y auditoría:
 
-- a. Auditar cualquier cambio del maestro de Productos. Se debe llevar un registro detallado de
-- las inserciones, modificaciones y borrados, en todos los casos registrar desde que PC se
-- hacen los movimientos (HOST_NAME()), la fecha y la hora, el usuario y todos los datos que permitan una
-- correcta auditoría (si son modificaciones que datos se modificaron, qué datos había antes,
-- que datos hay ahora, etc). La/s estructura/s necesaria para este punto es libre y queda a
-- criterio del alumno


	CREATE TABLE Auditoria(
		IdAudit INT IDENTITY(1,1),
		Tabla VARCHAR(30), 
		Host VARCHAR(30),
		Fecha DATETIME,
		Usuario NVARCHAR(128),
		Operación VARCHAR(20),
		Viejo NVARCHAR(128),
		Actual NVARCHAR(128),
		Observaciones VARCHAR(100)

		CONSTRAINT PK_IdAuditoria PRIMARY KEY (idAudit)
	)


	CREATE TRIGGER AuditarCambioMaestroProductos
	ON Producto
	AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @tipo CHAR(1)

		IF EXISTS (SELECT * FROM Inserted) AND NOT EXISTS (SELECT * FROM Deleted) -- INSERT - 
			SET @tipo = 'I'
		ELSE IF EXISTS (SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted) -- UPDATE - 
			SET @tipo = 'U'

		--	SE COMPRUEBA EL CAMPO DE LA TABLA
		IF @tipo = 'I'
			INSERT INTO Auditoria SELECT 'Producto', HOST_NAME(), GETDATE(), System_User, 'INSERT', 
				NULL, i.CodProducto + ' - ' + i.Descripcion + ' - $' + CONVERT(NVARCHAR(128),i.PrecioUnitario), 'Se agrego el producto de Codigo: ' + i.CodProducto
			FROM Inserted i
			WHERE i.CodProducto IN (SELECT CodProducto FROM Inserted)

		ELSE IF @tipo = 'U'
			INSERT INTO Auditoria SELECT 'Producto', HOST_NAME(), GETDATE(), System_User, 'UPDATE', 
				d.CodProducto + ' - ' + d.Descripcion + ' - $' + CONVERT(NVARCHAR(128), d.PrecioUnitario), 
				i.CodProducto + ' - ' + i.Descripcion + ' - $' + CONVERT(NVARCHAR(128),i.PrecioUnitario), 
				'Se modifico el producto de Codigo: ' + d.CodProducto
			FROM Inserted i, Deleted d
			WHERE	i.CodProducto = d.CodProducto
			AND		i.CodProducto IN (SELECT CodProducto FROM Inserted)
	END

	CREATE TRIGGER AuditarBorradoDeProductos
    ON Producto
    INSTEAD OF DELETE
    AS 
    BEGIN
		DELETE FROM Nutrientes WHERE CodProducto IN  (	SELECT CodProducto
														FROM Deleted d ) 
		
		DELETE FROM Producto WHERE CodPRoducto IN (	SELECT CodProducto
													FROM Deleted d )
		
        INSERT INTO Auditoria	SELECT 'Producto', HOST_NAME(), GETDATE(), System_User, 'DELETE', d.CodProducto + ' - ' + d.Descripcion + ' - $' + CONVERT(NVARCHAR(128), d.PrecioUnitario), NULL, 'Se borro el producto de Codigo: ' + d.CodProducto
								FROM Deleted d
								WHERE d.CodProducto IN (SELECT CodProducto FROM Deleted)
    END


	INSERT INTO Producto VALUES ('PRB01','Prueba 1', 50)
	INSERT INTO Producto VALUES ('PRB02','Prueba 3', 50)

	SELECT * FROM Producto
	SELECT * FROM Auditoria
		
	UPDATE Producto
	SET Descripcion = 'Prueba trigger update'
	WHERE CodProducto = 'PRB01'

	SELECT * FROM Producto
	SELECT * FROM Auditoria


	UPDATE Producto
	SET PrecioUnitario = 100

	SELECT * FROM Producto
	SELECT * FROM Auditoria
		
	DELETE FROM Producto WHERE CodProducto = 'PRB01'
	DELETE FROM Producto WHERE CodProducto = 'PRB02'
	DELETE FROM Producto WHERE CodProducto = 'ABO11'

	SELECT * FROM Producto
	SELECT * FROM Auditoria

	DELETE FROM Producto

	SELECT * FROM Producto
	SELECT * FROM Auditoria



-- b. Controlar que no se pueda dar de alta un mantenimiento cuya fecha-hora es menor que la
-- fecha de nacimiento de la planta

	-- ES PARA INSERTS DE UNA LINEA!!

	CREATE TRIGGER MantenimientoPrevioAFechaNacPlanta
	ON Mantiene
	INSTEAD OF INSERT
	AS
	BEGIN
		DECLARE @idMantenimiento INT = (SELECT i.IdMantenimiento FROM Inserted i)
		
		-- SI LA FECHA ESTA BIEN 
		IF (SELECT m.FechaHora
			FROM	Inserted i, Mantenimiento m
			WHERE	i.IdMantenimiento = m.IdMantenimiento) 
			>
			(SELECT p.FechaNac
			FROM Inserted i, Planta p
			WHERE	i.IdPlanta = p.IdPlanta)
		BEGIN -- LE HACEMOS INSERT
			INSERT INTO Mantiene SELECT i.IdPlanta, i.IdMantenimiento
			FROM Inserted i
			WHERE i.IdMantenimiento = @idMantenimiento
		END
		
	END

	CREATE TRIGGER MantenimientoOperativo
	ON Operativo
	INSTEAD OF INSERT 
	AS
	BEGIN
		DECLARE @idMant int =	(SELECT IdMantenimiento
								FROM Inserted)

		IF (@idMant in (SELECT IdMantenimiento FROM Mantiene))
			INSERT INTO Operativo SELECT i.*
			FROM Inserted i
			WHERE i.IdMantenimiento = @idMant

	END

	CREATE TRIGGER MantenimientoNutrientes
	ON Nutrientes
	INSTEAD OF INSERT 
	AS
	BEGIN
		DECLARE @idMant int =	(SELECT IdMantenimiento
								FROM Inserted)
								
		IF (@idMant in (SELECT IdMantenimiento FROM Mantiene))
			INSERT INTO Nutrientes SELECT i.*
			FROM Inserted i
			WHERE i.IdMantenimiento = @idMant

	END

	INSERT INTO Mantenimiento VALUES ('14/6/2020',		'Mantenimiento 32')
	SELECT * FROM Mantenimiento
	
	INSERT INTO Mantiene VALUES (1,32)
	SELECT * FROM Mantiene
	
	INSERT INTO Operativo VALUES (32,1,100)
	SELECT * FROM Operativo

	INSERT INTO Nutrientes VALUES (32,'FER01',7,5)
	SELECT * FROM Nutrientes