-- Sebastian Alvarez (257209)
-- Andres Mayes (230729)
-- Juan Martinez (275957)
 
	CREATE DATABASE ViveroPflanzeObligatorio;
	
	USE ViveroPflanzeObligatorio;
	SET DATEFORMAT dmy

------------------------------------------------------------------
-- Creacion tablas
------------------------------------------------------------------


	CREATE TABLE Planta (
		IdPlanta int identity(1,1),
		Nombre varchar(30) not null, 
		FechaNac datetime not null,
		Altura decimal,
		FechaUltimaMedicion datetime,
		Precio decimal(5,2) null,

		CONSTRAINT PK_IdPlanta PRIMARY KEY (IdPlanta),
		CONSTRAINT CK_AlturaPositiva CHECK (Altura > 0),
		CONSTRAINT CK_AlturaMenor12000cm CHECK (Altura < 12000),
		CONSTRAINT CK_PrecioPositivo CHECK (Precio > 0),
		CONSTRAINT CK_FechaNacPlantaMenorAHoy CHECK (FechaNac <= GetDate()),
		CONSTRAINT CK_FechaUltimaMedicionPlantaMenorAHoy CHECK (FechaUltimaMedicion <= GetDate()),
		CONSTRAINT CK_FechaUltimaMedicionPlantaMayorAFechaNac CHECK (FechaUltimaMedicion >= FechaNac),
		CONSTRAINT CK_FechaUltimaMedicionNoNullSiHayAltura CHECK ((Altura IS NOT NULL AND FechaUltimaMedicion IS NOT NULL) OR (Altura IS NULL AND FechaUltimaMedicion IS NULL)),
	)

	CREATE INDEX i_FechaNacPlanta ON Planta(FechaNac)

	CREATE TABLE Tag (
		IdTag int identity(1,1),
		Descripcion varchar(30) not null,

		CONSTRAINT PK_IdTag PRIMARY KEY (IdTag)
	)

	CREATE TABLE Mantenimiento (
		IdMantenimiento int identity(1,1), 
		FechaHora datetime not null,
		Descripcion varchar(50) not null,

		CONSTRAINT PK_IdMantenimiento PRIMARY KEY (IdMantenimiento)
	)

	CREATE INDEX i_FechaHoraMantenimiento ON Mantenimiento(FechaHora)

	CREATE TABLE Describe (
		IdPlanta int not null, 
		IdTag int not null,

		CONSTRAINT PK_IdsDescripcionPlantaTag PRIMARY KEY (IdPlanta, IdTag),
		CONSTRAINT FK_IdPlanta FOREIGN KEY (IdPlanta) REFERENCES Planta(IdPlanta),
		CONSTRAINT FK_IdTag FOREIGN KEY (IdTag) REFERENCES Tag(IdTag)
	)

	CREATE INDEX i_IdPlantaDescribe ON Describe(IdPlanta)
	CREATE INDEX i_IdTagDescribe ON Describe(IdTag)
	
	
	-- TABLA INNECESARIA QUE AL HACER PASAJE A TABLAS PENSAMOS QUE UN MISMO MANTENIMIENTO SE PODIA HACER PARA VARIAS PLANTAS. 
	-- FUE CONSULTADO A PROFE Y DIO EL OK PARA CONSERVARLA
	CREATE TABLE Mantiene (
		IdPlanta int not null, 
		IdMantenimiento int not null,

		CONSTRAINT PK_IdsMantienePlantaMantenimiento PRIMARY KEY (IdPlanta, IdMantenimiento),
		CONSTRAINT FK_IdPlantaMantiene FOREIGN KEY (IdPlanta) REFERENCES Planta(IdPlanta),
		CONSTRAINT FK_IdMantenimientoMantiene FOREIGN KEY (IdMantenimiento) REFERENCES Mantenimiento(IdMantenimiento)
	)

	CREATE INDEX i_IdPlantaMantiene ON Mantiene(IdPlanta)
	CREATE INDEX i_IdMantenimientoMantiene ON Mantiene(IdMantenimiento)


	CREATE TABLE Operativo (
		IdMantenimiento int not null, 
		HorasTrabajo decimal(4,2) not null, 
		Costo decimal(5,2) not null,

		CONSTRAINT PK_MantenimientoOperativo PRIMARY KEY (IdMantenimiento),
		CONSTRAINT FK_IdMantenimientoOperativo FOREIGN KEY (IdMantenimiento) REFERENCES Mantenimiento(IdMantenimiento),
		CONSTRAINT CK_HorastrabajoOperativoPositivo CHECK (HorasTrabajo > 0),
		CONSTRAINT CK_CostoOperativoPositivo CHECK (Costo > 0)
	)

	CREATE INDEX i_IdMantenimientoOperativo ON Operativo(IdMantenimiento)
	CREATE INDEX i_CostoOperativo ON Operativo(Costo)

	CREATE TABLE Producto (
		CodProducto character(5) not null, 
		Descripcion varchar(40) not null unique, 
		PrecioUnitario decimal(5,2) not null,

		CONSTRAINT PK_CodProducto PRIMARY KEY (CodProducto),
		CONSTRAINT CK_PrecioUnitarioProductoPositivo CHECK (PrecioUnitario > 0)
	)

	CREATE INDEX i_PrecioUnitarioProducto ON Producto(PrecioUnitario)

	CREATE TABLE Nutrientes (
		IdMantenimiento int not null, 
		CodProducto character(5) not null, 
		Cantidad int not null, 
		CostoAplicacion decimal(6,2) not null,

		CONSTRAINT PK_MantenimientoNutrientesUsoProductos PRIMARY KEY (IdMantenimiento, CodProducto),
		CONSTRAINT FK_IdMantenimientoNutrientesUsoProductos FOREIGN KEY (IdMantenimiento) REFERENCES Mantenimiento(IdMantenimiento),
		CONSTRAINT FK_CodProductoNutrientesUsoProductos FOREIGN KEY (CodProducto) REFERENCES Producto(CodProducto),
		CONSTRAINT CK_CantidadNutrientesPositivo CHECK (Cantidad > 0),
		CONSTRAINT CK_CostoAplicacionUsoPositivo CHECK (CostoAplicacion > 0)
	)

	CREATE INDEX i_IdMantenimientoNutrientes ON Nutrientes(IdMantenimiento)
	CREATE INDEX i_CodProductoNutrientes ON Nutrientes(CodProducto)
	CREATE INDEX i_CantidadNutrientes ON Nutrientes(Cantidad)
	CREATE INDEX i_CostoAplicacionNutrientes ON Nutrientes(CostoAplicacion)

-------------------------------------------------------------------------------------------
-- INSERTS
-------------------------------------------------------------------------------------------
-- Planta (IdPlanta, Nombre, FechaNac, Altura, FechaUltimaMedicion, Precio)
	
	INSERT INTO Planta (Nombre, FechaNac, Altura, FechaUltimaMedicion, Precio) VALUES 
						('Tronco de Brasil',		'15/6/2020',	150.00,		'22/2/2021',	10.5),			-- 1
						('Bromelia',				'8/8/2019',		200.00,		'2/2/2022',		20.0),			-- 2
						('Areca simplificada',		'1/8/2017',		502.00,		'22/2/2022',	50.0),			-- 3
						('Croton',					'5/4/2018',		70.00,		'1/8/2019',		110.0),			-- 4
						('Espada de San Jorge ',	'3/11/2019',	640.00,		'26/12/2019',	6.99),			-- 5
						('Planta de la oraci�n',	'14/1/2022',	1004.00,	'22/2/2022',	4.3	),			-- 6	
						('Aloe Vera',				'30/1/2016',	3451.00,	'12/11/2017',	10.0),			-- 7
						('Cinta',					'2/1/2018',		456.00,		'5/6/2021',		60.0),			-- 8
						('Palmera bamb�',			'30/12/2021',	11000.00,	'6/1/2022',		86.4),			-- 9
						('Naranjo',					'1/4/2017',		40.00,		'5/4/2022',		44.4),			-- 10
						('Cactus',					'24/9/2019',	200.45,		'12/3/2022',	NULL),			-- 11
						('Ceibo',					'31/5/2020',	120.00,		'1/6/2021',		50.5)			-- 12


-- Tag (IdTag , Descripcion)
	
	Insert into Tag (Descripcion) VALUES 
			('FRUTAL'), ('SINFLOR'), ('CONFLOR'), ('SOMBRA'), ('HIERBA'), ('PERFUMA'), ('TRONCODOBLADO'), ('TRONCOROTO')

 -- Mantenimiento (IdMantenimiento, Fecha-Hora, Descripcion)
	INSERT INTO Mantenimiento (FechaHora, Descripcion) VALUES 
			('1/5/2021 07:29:00:000',		'Mantenimiento 1'),
			('9/6/2021 16:21:00:000',		'Mantenimiento 2'),
			('31/1/2022 16:21:00:000',		'Mantenimiento 3'),
			('11/12/2021 14:03:00:000',		'Mantenimiento 4'),
			('3/7/2020 09:57:00:000',		'Mantenimiento 5'),
			('12/03/2020 12:10:00:000 ',	'Mantenimiento 6'),
			('15/09/2021 10:00:00:000' ,	'Mantenimiento 7'),
			('20/12/2021 17:15:00:000' ,	'Mantenimiento 8'),
			('20/08/2020 16:30:00:000' ,	'Mantenimiento 9'),
			('1/02/2022 14:45:00:000' ,		'Mantenimiento 10'),
			----------------------------------------------------
			('28/2/2022 14:30:00:000',		'Mantenimiento 11'),
			('14/11/2021 8:40:00:000',		'Mantenimiento 12'), 
			('27/7/2021 17:15:00:000',		'Mantenimiento 13'),
			('7/3/2021 12:05:00:000',		'Mantenimiento 14'),
			('4/12/2021 11:50:00:000',		'Mantenimiento 15'),
			('7/8/2021 07:29:00:000',		'Mantenimiento 16'),
			('2/2/2018 08:17:00:000',		'Mantenimiento 17'),
			('1/2/2022 19:46:00:000',		'Mantenimiento 18'),
			('3/5/2022 14:09:00:000',		'Mantenimiento 19'),
			('10/5/2022 07:30:00:000',		'Mantenimiento 20'),
			----------------------------------------------------
			('19/2/2021 11:57:00:000',		'Mantenimiento 21'),
			('11/12/2021 09:29:00:000',		'Mantenimiento 22'),
			('1/11/2021 12:12:00:000',		'Mantenimiento 23'),
			('2/2/2022 16:30:00:000',		'Mantenimiento 24'),
			('4/10/2020 19:45:00:000',		'Mantenimiento 25'),
			('20/8/2021 17:05:00:000',		'Mantenimiento 26'),
			('12/3/2022 15:45:00:000',		'Mantenimiento 27'),
			('28/10/2019 12:55:00:000',		'Mantenimiento 28'),
			('16/12/2018 16:15:00:000',		'Mantenimiento 29'),
			('24/8/2021 16:15:00:000',		'Mantenimiento 30'),
			('24/8/2021 16:15:00:000',		'Mantenimiento 31')
			
-- Describe (IdPlanta, IdTag)
	Insert into Describe (IdPlanta,IdTag) VALUES 
			(1,1), (1,2), (2,6), (2,7), (2,5), (2,8), (3,7), (3,1), (3,6), (4,3), (4,6), (4,8), (4,5), (5,4), (5,1), (5,6), (5,8), 
			(6,4), (6,8), (7,6), (7,1), (8,5), (8,8), (9,3), (10,1), (10,6), (11,1), (11,6)

	INSERT INTO Mantiene (IdPlanta, IdMantenimiento) VALUES 
			(2, 1), (3, 2), (5, 3), (1, 4), (4, 5), (7, 6), (1, 7), (2, 8), (2, 9), (9, 10), (3, 11), (6,12), (8, 13), (5, 14), (1, 15), 
			(1,16), (2,17), (3,18), (4,19), (5,20), (6,21), (7,22), (8,23), (9,24), (5,25), (3,26), (8,27), (6,28), (1,29), (5,30),
			(12,31)


	Insert into Producto VALUES 
			('FER01',	'Fertilizante de origen animal',			0.25),
			('ABO11',	'Abono 100% organico',						0.10), 
			('SUS07',	'Sustrato para semillas de todo tipo',		1.30),
			('MIX15',	'Mix de sustrato para macetas',				0.55),
			('COM02',	'Compost premium',							1.40) 



	INSERT INTO Operativo VALUES	(1,  6,  15),
									(2,  1,  10),
									(3,  7,  18),
									(4,	 1,  4),
									(5,	 2,  10),
									(6,	 8,  20),
									(7,	 5,  25),
									(8,	 3,  15),
									(9,	 2,  10),
									(10, 8,  30),
									(11, 6,  22),
									(12, 2,  10),
									(13, 2,  18),
									(30, 12, 500),
									(31, 1,  100)

	INSERT INTO Nutrientes VALUES
			(14,'FER01',7,5),
			(14,'SUS07',1,1),
			(14,'MIX15',2,2),
			(15,'SUS07',4,2),
			(15,'FER01',4,2),
			(16,'MIX15',1,10),
			(16,'SUS07',12,3),
			(16,'COM02',1,2),
			(17,'ABO11',2,5),
			(18,'COM02',2,6),
			(18,'SUS07',5,9),
			(19,'MIX15',1,5),
			(19,'ABO11',2,4),
			(19,'SUS07',3,3),
			(19,'FER01',4,2),
			(19,'COM02',5,1),
			(20,'FER01',5,3),
			(20,'ABO11',2,3),
			(20,'SUS07',1,4),
			(20,'COM02',3,6),
			(21,'COM02',2,6),
			(22,'ABO11',2,4),
			(22,'SUS07',4,2),
			(23,'ABO11',1,10),
			(23,'COM02',5,20),
			(24,'MIX15',2,3),
			(24,'ABO11',2,12),
			(25,'FER01',2,5),
			(25,'ABO11',1,5),
			(26,'COM02',5,6),
			(26,'ABO11',3,4),
			(26,'MIX15',8,11),
			(27,'FER01',3,2),
			(27,'MIX15',4,9),
			(28,'SUS07',1,7),
			(28,'ABO11',1,5),
			(29,'COM02',3,5)



	--DROP TABLE Nutrientes
	--DROP TABLE Producto
	--DROP TABLE Operativo
	--DROP TABLE Mantiene
	--DROP TABLE Mantenimiento
	--DROP TABLE Describe
	--DROP TABLE Tag
	--DROP TABLE Planta