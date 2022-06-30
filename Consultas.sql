-- Sebastian Alvarez (257209)
-- Andres Mayes (230729)
-- Juan Martinez (275957)

	USE ViveroPflanzeObligatorio;
	SET DATEFORMAT dmy

-------------------------------------------------------------------------------------------
-- CONSULTAS
-------------------------------------------------------------------------------------------

-- a. Mostrar Nombre de Planta y Descripción del Mantenimiento para el último(s)
-- mantenimiento hecho en el año actual

	SELECT p.Nombre, m.Descripcion
	FROM Planta p, Mantenimiento m, Mantiene ma
	WHERE	p.IdPlanta = ma.IdPlanta 
	AND		ma.IdMantenimiento = m.IdMantenimiento 
	AND		m.FechaHora = (	SELECT MAX(FechaHora) UltimoMantenimiento 
							FROM Mantenimiento 
							WHERE YEAR(FechaHora) = YEAR(GETDATE()))




-- b. Mostrar la(s) plantas que recibieron más cantidad de mantenimientos.

	SELECT p.*, COUNT(*) CantidadMantenimientos 
	FROM Planta p, Mantenimiento m, Mantiene ma
	WHERE	p.IdPlanta = ma.IdPlanta 
	AND		ma.IdMantenimiento = m.IdMantenimiento
	GROUP BY p.IdPlanta, Nombre, FechaNac, Altura, FechaUltimaMedicion, Precio
	HAVING COUNT(*) >= ALL(SELECT COUNT(*) FROM Mantiene GROUP BY IdPlanta) 




-- c.	Mostrar las plantas que este año ya llevan más de un 20% de costo de mantenimiento que el costo de mantenimiento 
--		de todo el año anterior para la misma planta ( solo considerar plantas nacidas en el año 2019 o antes).

	SELECT p.*
	FROM Planta p 
	LEFT JOIN	(SELECT p.IdPlanta, SUM(Mantenimientos) MantenimientosEA
				FROM (	(
					SELECT ma.Idplanta, SUM(Costo) Mantenimientos
					FROM Operativo o, Mantenimiento m, Mantiene ma
					WHERE	ma.IdMantenimiento = m.IdMantenimiento
					AND		m.IdMantenimiento = o.IdMantenimiento
					AND		YEAR(FechaHora) = YEAR(GETDATE())
					GROUP BY ma.IdPlanta
				) 
				UNION
				(
					SELECT ma.Idplanta, SUM(PrecioUnitario * Cantidad + CostoAplicacion) Mantenimientos
					FROM Mantenimiento m, Mantiene ma, Nutrientes n, Producto p
					WHERE	m.IdMantenimiento = ma.IdMantenimiento
					AND		ma.IdMantenimiento = n.IdMantenimiento
					AND		n.CodProducto = p.CodProducto
					AND		YEAR(FechaHora) = YEAR(GETDATE())
					GROUP BY ma.IdPlanta
				)) AS m, Planta p
				WHERE p.IdPlanta = m.IdPlanta
				GROUP BY p.IdPlanta) AS mea 
	ON p.IdPlanta = mea.IdPlanta
	LEFT JOIN	(SELECT p.IdPlanta, SUM(Mantenimientos) MantenimientosAA
				FROM (
				(
					SELECT ma.Idplanta, SUM(Costo) Mantenimientos
					FROM Operativo o, Mantenimiento m, Mantiene ma
					WHERE	ma.IdMantenimiento = m.IdMantenimiento
					AND		m.IdMantenimiento = o.IdMantenimiento
					AND		YEAR(FechaHora) = YEAR(GETDATE()) - 1
					GROUP BY ma.IdPlanta
				) 
				UNION
				(
					SELECT ma.Idplanta, SUM(PrecioUnitario * Cantidad + CostoAplicacion) Mantenimientos
					FROM Mantenimiento m, Mantiene ma, Nutrientes n, Producto p
					WHERE	m.IdMantenimiento = ma.IdMantenimiento
					AND		ma.IdMantenimiento = n.IdMantenimiento
					AND		n.CodProducto = p.CodProducto
					AND		YEAR(FechaHora) = YEAR(GETDATE()) - 1
					GROUP BY ma.IdPlanta
				)) AS m, Planta p
				WHERE p.IdPlanta = m.IdPlanta
				GROUP BY p.IdPlanta) AS maa 
	ON mea.IdPlanta = maa.IdPlanta
	WHERE	mea.MantenimientosEA >= ((Isnull(maa.MantenimientosAA, 0)) / 5) 
	AND		YEAR(p.FechaNac) <= 2019




-- d.	Mostrar las plantas que tienen el tag “FRUTAL”, a la vez tienen el tag “PERFUMA” y no tienen el tag “TRONCOROTO”. 
--		Y que adicionalmente miden medio metro de altura o más y tienen un precio de venta establecido.

	SELECT DISTINCT p.*
	FROM Planta p, Describe d, Tag t
	WHERE	p.IdPlanta = d.IdPlanta
	AND		p.Altura >= 50
	AND		p.Precio IS NOT NULL
	AND		d.IdTag = t.IdTag
	AND		p.IdPlanta 
	IN		(SELECT IdPlanta
			FROM Describe d, Tag t
			WHERE t.IdTag = d.IdTag
			AND t.Descripcion = 'FRUTAL')
	AND		p.IdPlanta 
	IN 		(SELECT IdPlanta
			FROM Describe d, Tag t
			WHERE t.IdTag = d.IdTag
			AND t.Descripcion = 'PERFUMA')
	AND		p.IdPlanta
	NOT IN	(SELECT IdPlanta
			FROM Describe d, Tag t
			WHERE t.IdTag = d.IdTag
			AND t.Descripcion = 'TRONCOROTO')




-- e.	Mostrar las Plantas que recibieron mantenimientos que en su conjunto incluyen todos los productos existentes.

	SELECT pla.*
	FROM Planta pla
	WHERE pla.IdPlanta IN (
		SELECT pl.IdPlanta
		FROM Planta pl, Mantiene ma, Nutrientes n, Producto p 
		WHERE	pl.IdPlanta = ma.IdPlanta
		AND		ma.IdMantenimiento = n.IdMantenimiento
		AND		n.CodProducto = p.CodProducto
		GROUP BY pl.IdPlanta
		HAVING COUNT(DISTINCT p.CodProducto) = (SELECT COUNT(CodProducto) FROM Producto)
)




-- f.	Para cada Planta con 2 años de vida o más y con un precio menor a 200 dólares:
--		sumarizar su costo de Mantenimiento total ( contabilizando tanto mantenimientos de
--		tipo “OPERATIVO” como de tipo “NUTRIENTES”) y mostrar solamente las plantas que
--		su costo sumarizado es mayor que 100 dólares.

	SELECT p.IdPlanta, m.Mantenimientos AS 'Mantenimientos totales', DATEDIFF(DAY,p.FechaNac,GETDATE()) AS 'Dias de vida', p.Precio
	FROM Planta p, (SELECT p.IdPlanta, SUM(Mantenimientos) Mantenimientos
					FROM (
					(
						SELECT ma.Idplanta, SUM(Costo) Mantenimientos
						FROM Operativo o, Mantenimiento m, Mantiene ma
						WHERE	ma.IdMantenimiento = m.IdMantenimiento
						AND		m.IdMantenimiento = o.IdMantenimiento
						GROUP BY ma.IdPlanta
					)
					UNION
					(
						SELECT ma.Idplanta, SUM(PrecioUnitario * Cantidad + CostoAplicacion) Mantenimientos
						FROM Mantenimiento m, Mantiene ma, Nutrientes n, Producto p
						WHERE	m.IdMantenimiento = ma.IdMantenimiento
						AND		ma.IdMantenimiento = n.IdMantenimiento
						AND		n.CodProducto = p.CodProducto
						GROUP BY ma.IdPlanta
					)) AS ma, Planta p
					WHERE p.IdPlanta = ma.IdPlanta
					GROUP BY p.IdPlanta) AS m
	WHERE	p.IdPlanta = m.IdPlanta
	AND		DATEDIFF(DAY,p.FechaNac,GETDATE()) >= 730
	AND		p.Precio <= 200
	AND		m.Mantenimientos >= 100


