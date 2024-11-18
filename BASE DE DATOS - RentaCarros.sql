/*
GRUPO RENTA CARROS

INTEGRANTES:
	- Juan Jos� Medina Sep�lveda
	- Nathalie Gabriela Miranda Rej�n
	- Sebasti�n Jes�s P�rez Araujo
	- Samuel Quiroz Rinc�n

*/

-- SE CREA LA BASE DE DATOS
CREATE DATABASE db_RentaCarros
GO

-- SE HACE USO DE LA BASE DE DATOS CREADA
USE db_RentaCarros
GO

---------------------------------------------------------
               -- SE CREAN LAS TABLAS --
---------------------------------------------------------
-- Tabla Membres�as
CREATE TABLE Membresias (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
);
-- Tabla Clientes
CREATE TABLE Clientes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Cedula NVARCHAR(20) NOT NULL UNIQUE,
    Direccion NVARCHAR(200),
    Edad INT,
    Membresia INT NOT NULL,
    CONSTRAINT FK_Clientes_Membresias FOREIGN KEY (Membresia) REFERENCES Membresias(Id)
);

-- Tabla Veh�culos
CREATE TABLE Vehiculos (
    Id INT PRIMARY KEY IDENTITY(1,1),
	Placa NVARCHAR(10) NOT NULL UNIQUE,
    Tipo NVARCHAR(50) NOT NULL,
    Marca NVARCHAR(50) NOT NULL,
    Modelo NVARCHAR(50) NOT NULL,
    Kilometraje INT,
    Disponibilidad BIT NOT NULL DEFAULT 1
);

-- Tabla Sedes
CREATE TABLE Sedes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Direccion NVARCHAR(200) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL
);

-- Tabla Asesores
CREATE TABLE Asesores (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Cedula NVARCHAR(20) NOT NULL UNIQUE,
    Sede INT NOT NULL,
    CONSTRAINT FK_Asesores_Sedes FOREIGN KEY (Sede) REFERENCES Sedes(Id)
);

-- Tabla Alquileres
CREATE TABLE Alquileres (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Cliente INT NOT NULL,
    Asesor INT NOT NULL,
    Fecha_renta DATE NOT NULL,
    Fecha_finalizacion DATE,
    Valor DECIMAL(10,2),
    Vehiculo INT NOT NULL,
    CONSTRAINT FK_Alquileres_Clientes FOREIGN KEY (Cliente) REFERENCES Clientes(Id),
    CONSTRAINT FK_Alquileres_Asesores FOREIGN KEY (Asesor) REFERENCES Asesores(Id),
    CONSTRAINT FK_Alquileres_Vehiculos FOREIGN KEY (Vehiculo) REFERENCES Vehiculos(Id)
);
GO

---------------------------------------------------------
-- SE CREAN TRIGGERS PARA ACTUALIZAR LA DISPONIBILIDAD--
---------------------------------------------------------

--Creacion de trigger para actualizar la disponibilidad de los autos en alquiler
CREATE TRIGGER trg_UpdateDisponibilidadVehiculo
ON Alquileres
AFTER INSERT
AS
BEGIN
    UPDATE Vehiculos
    SET Disponibilidad = 0
    WHERE Id IN (SELECT Vehiculo FROM inserted);
END;
GO

---------------------------------------------------------
               -- SE INSERTAN DATOS EN LAS TABLAS --
---------------------------------------------------------

-- Datos para la tabla Membres�as
INSERT INTO Membresias (Nombre)
VALUES ('B�sica'), ('Premium'), ('VIP');

-- Datos para la tabla Clientes
INSERT INTO Clientes (Nombre, Cedula, Direccion, Edad, Membresia)
VALUES 
('Juan P�rez', '123456789', 'Calle Falsa 123', 35, 1),
('Mar�a L�pez', '987654321', 'Avenida Principal 456', 28, 2),
('Carlos Garc�a', '654321987', 'Carrera Secundaria 789', 40, 3),
('Sofia P�rez', '1278267392', 'Calle sur 78', 25, 2),
('Margarita Zapata', '987633563', 'Avenida Sedundaria 876', 28, 1);


-- Datos para la tabla Veh�culos
INSERT INTO Vehiculos (Placa, Tipo, Marca, Modelo, Kilometraje)
VALUES
('SWL789','SUV', 'Toyota', 'RAV4', 20000),
('HJL421', 'Sed�n', 'Honda', 'Civic', 15000),
('ERO734', 'Pickup',  'Ford', 'Ranger', 30000),
('MRT790', 'Deportivo', 'Chevrolet', 'Camaro', 10000);

-- Datos para la tabla Sedes
INSERT INTO Sedes (Direccion, Nombre)
VALUES
('Calle 1 #10-20', 'Sede Central'),
('Carrera 2 #15-30', 'Sede Norte'),
('Avenida 3 #20-40', 'Sede Sur');

-- Datos para la tabla Asesores
INSERT INTO Asesores (Nombre, Cedula, Sede)
VALUES
('Pedro Castillo', '111111111', 1),
('Luisa Mart�nez', '222222222', 2),
('Ana G�mez', '333333333', 3),
('Flor Gonzalez', '1111112344', 3),
('Pedro Escamozo', '2346722222', 1);
GO

---------------------------------------------------------
 -- SE CREAN TRANSACCIONES PARA INSERTAR ALQUILERES --
	   --CON SU RESPECTIVAS VERIFICACIONES --
---------------------------------------------------------

-- Datos para la tabla Alquileres (Uso de transaccion para veificar la consistencia de los datos ingresados)
BEGIN TRY
    -- Iniciar una transacci�n
    BEGIN TRANSACTION;

    -- Declaraci�n de variables, simulacion de entrada de datos
    DECLARE @ClienteId INT = 3;
    DECLARE @AsesorId INT = 1;
    DECLARE @FechaRenta DATE = '2022-10-10';
    DECLARE @FechaFinalizacion DATE = NULL;
    DECLARE @Valor DECIMAL(10, 2) = 500.00;
    DECLARE @VehiculoId INT = 4;

    -- Verificar que el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE Id = @ClienteId)
    BEGIN
        PRINT 'El cliente no existe.';
        ROLLBACK TRANSACTION;
        RETURN; --Uso de return para terminar el analisis en caso de que la condicion se cumpla
    END;

    -- Verificar que el asesor existe
    IF NOT EXISTS (SELECT 1 FROM Asesores WHERE Id = @AsesorId)
    BEGIN
        PRINT 'El asesor no existe.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Verificar que el veh�culo existe
    IF NOT EXISTS (SELECT 1 FROM Vehiculos WHERE Id = @VehiculoId)
    BEGIN
        PRINT 'El veh�culo no existe.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    -- Registrar el alquiler en la tabla Alquileres
    INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
    VALUES (@ClienteId, @AsesorId, @FechaRenta, @FechaFinalizacion, @Valor, @VehiculoId);

    -- Confirmar la transacci�n
    COMMIT TRANSACTION;
    PRINT 'Alquiler registrado correctamente.';
END TRY
BEGIN CATCH
    PRINT 'Ocurri� un error: ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH;

GO
----Agregamos mas datos a la tabla ALQUILERES

BEGIN TRY
    -- Iniciar una transacci�n
    BEGIN TRANSACTION;

    -- Declaraci�n de variables, simulacion de entrada de datos
    DECLARE @ClienteId INT = 4 ;
    DECLARE @AsesorId INT = 1;
    DECLARE @FechaRenta DATE = '2022-10-11';
    DECLARE @FechaFinalizacion DATE = '2022-10-23';
    DECLARE @Valor DECIMAL(10, 2) = 950.00;
    DECLARE @VehiculoId INT = 2;

    -- Verificar que el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE Id = @ClienteId)
    BEGIN
        PRINT 'El cliente no existe.';
        ROLLBACK TRANSACTION;
        RETURN; --Uso de return para terminar el analisis en caso de que la condicion se cumpla
    END;

    -- Verificar que el asesor existe
    IF NOT EXISTS (SELECT 1 FROM Asesores WHERE Id = @AsesorId)
    BEGIN
        PRINT 'El asesor no existe.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Verificar que el veh�culo existe
    IF NOT EXISTS (SELECT 1 FROM Vehiculos WHERE Id = @VehiculoId)
    BEGIN
        PRINT 'El veh�culo no existe.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    -- Registrar el alquiler en la tabla Alquileres
    INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
    VALUES (@ClienteId, @AsesorId, @FechaRenta, @FechaFinalizacion, @Valor, @VehiculoId);

    -- Confirmar la transacci�n
    COMMIT TRANSACTION;
    PRINT 'Alquiler registrado correctamente.';
END TRY
BEGIN CATCH
    PRINT 'Ocurri� un error: ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH;

GO

select * from alquileres;
GO
select * from vehiculos;
GO

---------------------------------------------------------
	    -- SE CREAN TRIGGERS PARA ACTUALIZAR --
	     -- EL KILOMETRAJE Y DISPONIBILIDAD --
---------------------------------------------------------

--Trigger que actualiza el kilometraje y disponibilidad de un auto luego de ser alquilado
	--Crear nueva columna null hasta que se edite
ALTER TABLE Alquileres
ADD Nuevo_Kilometraje decimal(10,2);
GO

	--Crear el Trigger
CREATE TRIGGER trg_UpdateKilometrajeDisponibilidad
ON Alquileres
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Fecha_finalizacion IS NOT NULL)
    BEGIN
        UPDATE Vehiculos
        SET Kilometraje = Kilometraje + (SELECT Nuevo_Kilometraje FROM inserted WHERE Vehiculo = Vehiculos.Id), 
		Disponibilidad = 1
        WHERE Id IN (SELECT Vehiculo FROM inserted);
    END;
END;
GO

---------------------------------------------------------
	      -- SE CREA UNA TRANSACCION PARA --
	     -- VERIFICAR SI UN ALQUILER EXISTE --
	  -- Y ACTUALIZAR SU FECHA DE FINALIZACI�N--
---------------------------------------------------------

--Transaccion para verificar si un alquiler existe, y actualizar su fecha de finalizacion y el kilometraje a�adido para el auto
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @FechaFinalizacion DATE = GETDATE();
	DECLARE @Nuevo_kilometraje DECIMAL(10,2) = 10000;
	DECLARE @IDvehiculo INT = 4;

    -- Verificar que el alquiler existe
    IF NOT EXISTS (SELECT 1 FROM Alquileres WHERE Vehiculo = @IDvehiculo AND Fecha_finalizacion IS NULL) 
    BEGIN
        PRINT 'El auto no est� alquilado';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Actualizar la fecha y kilometraje dentro de la tabla de alquileres
    UPDATE Alquileres
	SET Fecha_finalizacion = @FechaFinalizacion, Nuevo_Kilometraje = @Nuevo_kilometraje
	WHERE Vehiculo = @IDvehiculo;


    -- Confirmar la transacci�n
    COMMIT TRANSACTION;
    PRINT '	Alquiler actualizado con exito';
END TRY
BEGIN CATCH
    PRINT 'Ocurri� un error: ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH;
GO


---------------------------------------------------------
                       -- VISTAS --
---------------------------------------------------------

CREATE VIEW Vista_Alquileres AS
SELECT 
    Alqui.Id AS AlquilerID,
    Cli.Nombre AS Cliente_Nombre,
    Cli.Cedula AS Cliente_Cedula,
    Ase.Nombre AS Asesor_Nombre,
    Ase.Cedula AS Asesor_Cedula,
    Vehi.Placa AS Placa_Vehiculo,
    Vehi.Marca AS Vehiculo_Marca,
    Alqui.Fecha_renta,
    Alqui.Fecha_finalizacion,
    Alqui.Valor
FROM 
    Alquileres Alqui
JOIN 
    Clientes Cli ON Alqui.Cliente = Cli.Id
JOIN 
    Asesores Ase ON Alqui.Asesor = Ase.Id
JOIN 
    Vehiculos Vehi ON Alqui.Vehiculo = Vehi.Id;
GO

SELECT * FROM Vista_Alquileres;
GO

CREATE VIEW Vista_AlquileresPorSedeYAsesor AS
SELECT 
    Asesores.Nombre AS 'Nombre Asesor',
    COUNT(Alquileres.Id) AS 'Asesor con Mas Alquiler por una sede'
FROM 
    Asesores
LEFT JOIN 
    Alquileres ON Asesores.Id = Alquileres.Asesor
WHERE 
    Asesores.Sede = 1
GROUP BY 
    Asesores.Nombre;
GO

SELECT * FROM Vista_AlquileresPorSedeYAsesor;
GO

---------------------------------------------------------
	    -- C|R|U|D PARA TABLAS EN SQL --
---------------------------------------------------------

--CREATE
	--Crear tablas
CREATE TABLE Da�os_Vehiculo(
	ID int primary key identity(1,1),
	Tipo_Da�o NVARCHAR(100),
	Descripcion NVARCHAR(MAX)
);
GO
	--Agregar valores a las tablas
INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
VALUES
(3, 2, '2022-12-21', NULL, 5000.00, 4);
GO

--Crear columnas nuevas a las tablas
ALTER TABLE Alquileres
ADD Costos_adicionales decimal(10,2);
GO

--READ (HACIENDO USO DEL ALGEBRA RELACIONAL)

SELECT Id FROM Clientes WHERE Membresia = 3;

SELECT Clientes.Nombre AS 'NombreClientes' ,Vehiculos.Marca AS'MarcaVehiculos' FROM Clientes CROSS JOIN Vehiculos; 

SELECT Marca, Kilometraje FROM Vehiculos;

SELECT Vehiculo FROM Alquileres INTERSECT SELECT Id FROM Vehiculos;


--UPDATE
	--Renombramiento de columnas en la base de datos
EXEC SP_RENAME 'Vehiculos.Disponibilidad', 'Disponible?', 'COLUMN';
SELECT * FROM Vehiculos;

EXEC SP_RENAME 'Vehiculos.Disponible?', 'Disponibilidad', 'COLUMN';
SELECT * FROM Vehiculos;

EXEC SP_RENAME 'Membresias.Nombre', 'Tipo', 'COLUMN';
select * froM Membresias;

EXEC SP_RENAME 'Membresias.Tipo', 'Nombre', 'COLUMN';
select * froM Membresias;
GO

	--Actualizaar valores dentro de las tablas
UPDATE Sedes
SET Nombre = 'Sede Molinos'
WHERE Id = 1

UPDATE Asesores
SET Sede = 3
WHERE Id = 2

UPDATE Asesores
SET Sede = 2
WHERE Id = 2

UPDATE Alquileres
SET Valor = 700.00
WHERE Asesor = 3

UPDATE Alquileres
SET Vehiculo = 3
WHERE Cliente = 3 and Asesor = 3;
GO

--DELETE

	--Borrar tablas
DROP TABLE Da�os_Vehiculo

	--Borrar columnas
ALTER TABLE Alquileres
DROP COLUMN Costos_adicionales;
GO

---------------------------------------------------------
         -- SE HACE USO DE LAS SUBCONSULTAS --
---------------------------------------------------------

--SUBCONSULTAS
SELECT Id,
	(SELECT MAX(Valor)
	FROM Alquileres
	WHERE Alquileres.Vehiculo = Vehiculos.Id)
	AS PrecioMaximoAlquiler
FROM Vehiculos;

SELECT Nombre,
	(SELECT COUNT(*)
	FROM Alquileres
	WHERE Alquileres.Asesor = Asesores.Id)
	AS MayoresAlquileresPorSede
FROM Asesores
WHERE Sede= 1


SELECT Nombre,
	(SELECT COUNT(*)
	FROM Alquileres
	WHERE Alquileres.Asesor = Asesores.Id)
	AS MayoresAlquileres
FROM Asesores;

---------------------------------------------------------
       -- SE HACE USO DE LOS TIPOS DE JOIN --
---------------------------------------------------------

---CONSULTAS CON JOIN
SELECT Asesores.Nombre, Sedes.Nombre FROM Asesores 
JOIN Sedes ON Asesores.Sede = Sedes.Id;

SELECT * FROM Asesores
INNER JOIN Sedes ON Asesores.Sede = Sedes.Id;

SELECT * FROM Alquileres 
LEFT JOIN Vehiculos ON Alquileres.Vehiculo = Vehiculos.Id;

SELECT * FROM Membresias 
RIGHT JOIN Clientes ON Membresias.Id = Clientes.Membresia;
GO


---------------------------------------------------------
	 -- C|R|U|D PARA TABLAS DE LA BASE DE DATOS --
		 -- CON PROCEDIMIENTOS ALMACENADOS --
---------------------------------------------------------

--- CREATE

-- Insertar Membresia
CREATE PROCEDURE InsertarMembresia
	@Nombre NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT Nombre FROM Membresias WHERE Nombre = @Nombre)
		BEGIN
			INSERT INTO Membresias (Nombre)
			VALUES (@Nombre)

			COMMIT TRANSACTION;
			PRINT 'Membres�a insertada con �xito.';
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;
			PRINT 'Error: La membres�a ya existe.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
	END CATCH
END
GO;

EXEC InsertarMembresia 'Prueba';
GO

SELECT * FROM Membresias;
GO

-- Insertar Cliente
CREATE PROCEDURE InsertarCliente
	@Nombre NVARCHAR(50),
	@Cedula NVARCHAR(20),
	@Direccion NVARCHAR(200),
	@Edad INT,
	@Membresia INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		-- VERIFICAMOS QUE LOS DATOS INSERTADOS NO ESTEN VACIOS
		IF @Nombre IS NOT NULL AND @Cedula IS NOT NULL AND @Edad IS NOT NULL AND @Membresia IS NOT NULL
		BEGIN
		-- VERIFICAMOS QUE LA MEMEBRESIA EXISTA EN LA TABLA MEMBRESIAS
			IF EXISTS (SELECT Id FROM Membresias WHERE Id = @Membresia)
			BEGIN
			-- VERIFICAMOS QUE LA CEDULA NO EST� REGISTRADA EN LA TABLA
				IF NOT EXISTS (SELECT Cedula FROM Clientes WHERE Cedula = @Cedula)
				BEGIN
					INSERT INTO Clientes (Nombre, Cedula, Direccion, Edad, Membresia)
					VALUES (@Nombre,@Cedula,@Direccion,@Edad,@Membresia)

					COMMIT TRANSACTION;
					PRINT 'Cliente insertado con �xito.';
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION;
					PRINT 'Error: El cliente ya existe.'
				END
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				PRINT 'Error: La membresia ingresada no es v�lida.'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Error: Uno de los datos requeridos est� vacio.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
	END CATCH
END
GO;

EXEC InsertarCliente 'Prueba','12321313','Calle 45b',55,1;
GO

SELECT * FROM Clientes;
GO

-- Insertar Vehiculo
CREATE PROCEDURE InsertarVehiculo
	@Placa NVARCHAR(10),
	@Tipo NVARCHAR(50),
	@Marca NVARCHAR(50),
	@Modelo NVARCHAR(50),
	@Kilometraje INT,
	@Disponibilidad BIT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		-- VERIFICAMOS QUE LOS DATOS INSERTADOS NO ESTEN VACIOS
		IF @Tipo IS NOT NULL AND @Marca IS NOT NULL AND @Modelo IS NOT NULL AND @Kilometraje IS NOT NULL AND @Placa IS NOT NULL
		BEGIN
		-- VERIFICAMOS QUE LA PLACA NO EST� REGISTRADA EN LA TABLA
			IF NOT EXISTS (SELECT Placa FROM Vehiculos WHERE Placa = @Placa)
			BEGIN
				INSERT INTO Vehiculos (Placa,Tipo, Marca, Modelo, Kilometraje)
				VALUES (@Placa,@Tipo,@Marca,@Modelo,@Kilometraje)

				COMMIT TRANSACTION;
				PRINT 'Vehiculo insertado con �xito.';
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				PRINT 'Error: El Vehiculo ya existe.'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Error: Uno de los datos requeridos est� vacio.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
	END CATCH
END
GO;

EXEC InsertarVehiculo 'SWE345','Deportivo','Porsche','2024',0,1;
GO

SELECT * FROM Vehiculos;
GO
-- Insertar Sede
CREATE PROCEDURE InsertarSede
	@Direccion NVARCHAR(200),
	@Nombre NVARCHAR(100)

AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		-- VERIFICAMOS QUE LOS DATOS INSERTADOS NO ESTEN VACIOS
		IF @Direccion IS NOT NULL AND @Nombre IS NOT NULL 
		BEGIN
		-- VERIFICAMOS QUE EL NOMBRE  NO EST� REGISTRADO EN LA TABLA
			IF NOT EXISTS (SELECT Nombre FROM Sedes WHERE Nombre = @Nombre)
			BEGIN
				INSERT INTO Sedes (Direccion, Nombre)
				VALUES (@Direccion, @Nombre)

				COMMIT TRANSACTION;
				PRINT 'Sede insertada con �xito.';
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				PRINT 'Error: La sede ya existe.'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Error: Uno de los datos requeridos est� vacio.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
	END CATCH
END
GO;

EXEC InsertarSede 'Calle 55a','Sede Secundaria';
GO

SELECT * FROM Sedes;
GO
-- Insertar Asesores
CREATE PROCEDURE InsertarAsesores
	@Nombre NVARCHAR(50),
	@Cedula NVARCHAR(20),
	@Sede INT

AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		-- VERIFICAMOS QUE LOS DATOS INSERTADOS NO ESTEN VACIOS
		IF @Nombre IS NOT NULL AND @Cedula IS NOT NULL AND @Sede IS NOT NULL
		BEGIN
		-- VERIFICAMOS QUE LA SEDE EXISTA EN LA TABLA SEDES
			IF EXISTS (SELECT Id FROM Sedes WHERE Id = @Sede)
			BEGIN
			-- VERIFICAMOS QUE LA CEDULA NO EST� REGISTRADA EN LA TABLA
				IF NOT EXISTS (SELECT Cedula FROM Asesores WHERE Cedula = @Cedula)
				BEGIN
					INSERT INTO Asesores (Nombre, Cedula, Sede)
					VALUES (@Nombre,@Cedula,@Sede)

					COMMIT TRANSACTION;
					PRINT 'Asesor insertado con �xito.';
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION;
					PRINT 'Error: El Asesor ya existe.'
				END
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				PRINT 'Error: La Sede ingresada no es v�lida.'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Error: Uno de los datos requeridos est� vacio.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
	END CATCH
END

EXEC InsertarAsesores 'Prueba','1232132131',3;
GO

SELECT * FROM Asesores;
GO

-- Insertar Alquileres
CREATE PROCEDURE InsertarAlquileres
	-- Declaraci�n de variables, simulacion de entrada de datos
    @ClienteId INT,
    @AsesorId INT,
    @FechaRenta DATE,
    @FechaFinalizacion DATE,
    @Valor DECIMAL(10, 2),
    @VehiculoId INT

AS
BEGIN

	BEGIN TRY
		-- Iniciar una transacci�n
		BEGIN TRANSACTION;

		-- Verificar que el cliente existe
		IF NOT EXISTS (SELECT 1 FROM Clientes WHERE Id = @ClienteId)
		BEGIN
			PRINT 'El cliente no existe.';
			ROLLBACK TRANSACTION;
			RETURN; --Uso de return para terminar el analisis en caso de que la condicion se cumpla
		END;

		-- Verificar que el asesor existe
		IF NOT EXISTS (SELECT 1 FROM Asesores WHERE Id = @AsesorId)
		BEGIN
			PRINT 'El asesor no existe.';
			ROLLBACK TRANSACTION;
			RETURN;
		END;

		-- Verificar que el veh�culo existe
		IF NOT EXISTS (SELECT 1 FROM Vehiculos WHERE Id = @VehiculoId)
		BEGIN
			PRINT 'El veh�culo no existe.';
			ROLLBACK TRANSACTION;
			RETURN;
		END;
		-- Registrar el alquiler en la tabla Alquileres
		INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
		VALUES (@ClienteId, @AsesorId, @FechaRenta, @FechaFinalizacion, @Valor, @VehiculoId);

		-- Confirmar la transacci�n
		COMMIT TRANSACTION;
		PRINT 'Alquiler registrado correctamente.';
	END TRY
	BEGIN CATCH
		PRINT 'Ocurri� un error: ' + ERROR_MESSAGE();
		ROLLBACK TRANSACTION;
	END CATCH;
END;
GO

EXEC InsertarAlquileres 3,5,'2024-10-11','',50000,2;
GO

SELECT * FROM Alquileres;
GO

-- READ

-- Consultar Membresias
CREATE PROCEDURE ConsultarMembresias

AS
BEGIN
	SELECT * FROM Membresias
END;
GO

EXEC ConsultarMembresias;
GO

-- Consultar Clientes
CREATE PROCEDURE ConsultarClientes
AS
BEGIN
	SELECT Clientes.Id,Clientes.Nombre,Clientes.Cedula,Clientes.Direccion,Clientes.Edad,Membresias.Nombre AS Membresia FROM Clientes
	JOIN Membresias ON Clientes.Id = Membresias.Id
END;
GO

EXEC ConsultarClientes;
GO

-- Consultar Vehiculos
CREATE PROCEDURE ConsultarVehiculos
AS
BEGIN
	SELECT * FROM Vehiculos
END;
GO

EXEC ConsultarVehiculos;
GO

-- Consultar Sedes
CREATE PROCEDURE ConsultarSedes

AS
BEGIN
	SELECT * FROM Sedes
END;
GO

EXEC ConsultarSedes;
GO

-- Consultar Asesores
CREATE PROCEDURE ConsultarAsesores
AS
BEGIN
	SELECT Asesores.Id, Asesores.Cedula,Asesores.Nombre,Sedes.Nombre AS Sede FROM Asesores
	JOIN Sedes ON Asesores.Id = Sedes.Id
END;
GO

EXEC ConsultarAsesores;
GO

-- Consultar Alquileres
CREATE PROCEDURE ConsultarAlquileres
AS
BEGIN
	SELECT Alquileres.Id, Clientes.Cedula AS 'Cedula Cliente', Clientes.Nombre AS 'Nombre Cliente', Asesores.Nombre AS 'Nombre Asesor'
	,Alquileres.Fecha_renta, Alquileres.Fecha_finalizacion,
	Alquileres.Valor, Vehiculos.Placa FROM Alquileres
	JOIN Clientes ON Alquileres.Id = Clientes.Id
	JOIN Asesores ON Alquileres.Id = Asesores.Id
	JOIN Vehiculos ON Alquileres.Id = Vehiculos.Id
END;
GO

EXEC ConsultarAlquileres;
GO

-- UPDATE

-- Actualizar Membresia Por ID
CREATE PROCEDURE ActualizarMembresiaPorID
    @MembresiaID INT,
    @NuevoNombre NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que la membres�a exista por su ID
        IF EXISTS (SELECT * FROM Membresias WHERE Id = @MembresiaID)
        BEGIN
            -- Actualizamos el nombre de la membres�a
            UPDATE Membresias
            SET Nombre = @NuevoNombre
            WHERE Id = @MembresiaID;

            COMMIT TRANSACTION;
            PRINT 'Membres�a actualizada con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: La membres�a con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

EXEC ActualizarMembresiaPorID 
    @MembresiaID = 2, 
    @NuevoNombre = 'Elite';
GO

-- Actualizar Cliente Por ID
CREATE PROCEDURE ActualizarClientePorID
    @ClienteID INT,
    @NuevoNombre NVARCHAR(100) = NULL,
    @NuevaCedula NVARCHAR(20) = NULL,
    @NuevaDireccion NVARCHAR(200) = NULL,
    @NuevaEdad INT = NULL,
    @NuevaMembresia INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que el cliente exista por su ID
        IF EXISTS (SELECT * FROM Clientes WHERE Id = @ClienteID)
        BEGIN
            -- Actualizamos los datos solo si se proporcionan
            UPDATE Clientes
            SET 
                Nombre = ISNULL(@NuevoNombre, Nombre),
                Cedula = ISNULL(@NuevaCedula, Cedula),
                Direccion = ISNULL(@NuevaDireccion, Direccion),
                Edad = ISNULL(@NuevaEdad, Edad),
                Membresia = ISNULL(@NuevaMembresia, Membresia)
            WHERE Id = @ClienteID;

            COMMIT TRANSACTION;
            PRINT 'Cliente actualizado con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: El cliente con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

EXEC ActualizarClientePorID 
    @ClienteID = 1, 
    @NuevoNombre = 'Juan Carlos P�rez', 
    @NuevaEdad = 36;
GO

-- Actualizar Vehiculo Por ID
CREATE PROCEDURE ActualizarVehiculoPorID
    @VehiculoID INT,
    @NuevoTipo NVARCHAR(50) = NULL,
    @NuevaPlaca NVARCHAR(10) = NULL,
    @NuevaMarca NVARCHAR(50) = NULL,
    @NuevoModelo NVARCHAR(50) = NULL,
    @NuevoKilometraje INT = NULL,
    @NuevaDisponibilidad BIT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que el veh�culo exista por su ID
        IF EXISTS (SELECT * FROM Vehiculos WHERE Id = @VehiculoID)
        BEGIN
            -- Actualizamos los datos solo si se proporcionan
            UPDATE Vehiculos
            SET 
                Tipo = ISNULL(@NuevoTipo, Tipo),
                Placa = ISNULL(@NuevaPlaca, Placa),
                Marca = ISNULL(@NuevaMarca, Marca),
                Modelo = ISNULL(@NuevoModelo, Modelo),
                Kilometraje = ISNULL(@NuevoKilometraje, Kilometraje),
                Disponibilidad = ISNULL(@NuevaDisponibilidad, Disponibilidad)
            WHERE Id = @VehiculoID;

            COMMIT TRANSACTION;
            PRINT 'Veh�culo actualizado con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: El veh�culo con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

EXEC ActualizarVehiculoPorID 
    @VehiculoID = 1,
    @NuevoTipo = 'Sedan',
    @NuevaPlaca = 'XYZ1234',
    @NuevaMarca = 'Toyota',
    @NuevoModelo = 'Corolla',
    @NuevaDisponibilidad = 0;
GO

-- Actualizar Sede Por ID

CREATE PROCEDURE ActualizarSedePorID
    @SedeID INT,
    @NuevaDireccion NVARCHAR(200) = NULL,
    @NuevoNombre NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que la sede exista por su ID
        IF EXISTS (SELECT * FROM Sedes WHERE Id = @SedeID)
        BEGIN
            -- Actualizamos los datos solo si se proporcionan
            UPDATE Sedes
            SET 
                Direccion = ISNULL(@NuevaDireccion, Direccion),
                Nombre = ISNULL(@NuevoNombre, Nombre)
            WHERE Id = @SedeID;

            COMMIT TRANSACTION;
            PRINT 'Sede actualizada con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: La sede con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

EXEC ActualizarSedePorID 
    @SedeID = 1,
    @NuevaDireccion = 'Avenida Central 123';
GO

-- Actualizar Asesor Por ID
CREATE PROCEDURE ActualizarAsesorPorID
    @AsesorID INT,
    @NuevoNombre NVARCHAR(100) = NULL,
    @NuevaCedula NVARCHAR(20) = NULL,
    @NuevaSede INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que el asesor exista por su ID
        IF EXISTS (SELECT * FROM Asesores WHERE Id = @AsesorID)
        BEGIN
            -- Actualizamos los datos solo si se proporcionan
            UPDATE Asesores
            SET 
                Nombre = ISNULL(@NuevoNombre, Nombre),
                Cedula = ISNULL(@NuevaCedula, Cedula),
                Sede = ISNULL(@NuevaSede, Sede)
            WHERE Id = @AsesorID;

            COMMIT TRANSACTION;
            PRINT 'Asesor actualizado con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: El asesor con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

EXEC ActualizarAsesorPorID 
    @AsesorID = 2, 
    @NuevoNombre = 'Luis Mart�nez', 
    @NuevaCedula = '9999999999', 
    @NuevaSede = 3;
GO

-- Actualizar Alquiler Por ID
CREATE PROCEDURE ActualizarAlquilerPorID
    @AlquilerID INT,
    @Cliente INT = NULL,
    @Asesor INT = NULL,
    @FechaRenta DATE = NULL,
    @FechaFinalizacion DATE = NULL,
    @Valor DECIMAL(10,2) = NULL,
    @Vehiculo INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificamos que el alquiler exista por su ID
        IF EXISTS (SELECT * FROM Alquileres WHERE Id = @AlquilerID)
        BEGIN
            -- Actualizamos los datos del alquiler solo si se proporcionan nuevos valores
            UPDATE Alquileres
            SET 
                Cliente = ISNULL(@Cliente, Cliente),
                Asesor = ISNULL(@Asesor, Asesor),
                Fecha_renta = ISNULL(@FechaRenta, Fecha_renta),
                Fecha_finalizacion = ISNULL(@FechaFinalizacion, Fecha_finalizacion),
                Valor = ISNULL(@Valor, Valor),
                Vehiculo = ISNULL(@Vehiculo, Vehiculo)
            WHERE Id = @AlquilerID;

            COMMIT TRANSACTION;
            PRINT 'Alquiler actualizado con �xito.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: El alquiler con ese ID no existe.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error en la transacci�n: ' + ERROR_MESSAGE();
    END CATCH
END
GO

Select * From Alquileres

EXEC ActualizarAlquilerPorID 
    @AlquilerID = 1,
    @Cliente = 2,
    @Asesor = 3,
    @FechaRenta = '2024-11-01', 
    @FechaFinalizacion = NULL, 
    @Vehiculo = 4;
GO

-- DELETE

--Eliminar Sede Por ID
CREATE PROCEDURE EliminarSedePorID 
    @SedeID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si la sede existe
        IF EXISTS (SELECT * FROM Sedes WHERE Id = @SedeID)
        BEGIN
            DELETE FROM Sedes WHERE Id = @SedeID;
            PRINT 'Sede eliminada correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'La sede no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarSedePorID 
    @SedeID = 1; 
GO

-- Eliminar Cliente Por ID
CREATE PROCEDURE EliminarClientePorID 
    @ClienteID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si el cliente existe
        IF EXISTS (SELECT * FROM Clientes WHERE Id = @ClienteID)
        BEGIN
            DELETE FROM Clientes WHERE Id = @ClienteID;
            PRINT 'Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El cliente no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarClientePorID 
    @ClienteID = 3;
GO

-- Eliminar Vehiculo Por ID
CREATE PROCEDURE EliminarVehiculoPorID 
    @VehiculoID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si el veh�culo existe
        IF EXISTS (SELECT * FROM Vehiculos WHERE Id = @VehiculoID)
        BEGIN
            DELETE FROM Vehiculos WHERE Id = @VehiculoID;
            PRINT 'Veh�culo eliminado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El veh�culo no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarVehiculoPorID 
    @VehiculoID = 1;
GO

-- Eliminar Membresia Por ID
CREATE PROCEDURE EliminarMembresiaPorID 
    @MembresiaID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si la membres�a existe
        IF EXISTS (SELECT * FROM Membresias WHERE Id = @MembresiaID)
        BEGIN
            DELETE FROM Membresias WHERE Id = @MembresiaID;
            PRINT 'Membres�a eliminada correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'La membres�a no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarMembresiaPorID 
    @MembresiaID = 2;
GO

-- Eliminar Asesor Por ID
CREATE PROCEDURE EliminarAsesorPorID 
    @AsesorID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si el asesor existe
        IF EXISTS (SELECT * FROM Asesores WHERE Id = @AsesorID)
        BEGIN
            DELETE FROM Asesores WHERE Id = @AsesorID;
            PRINT 'Asesor eliminado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El asesor no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarAsesorPorID 
    @AsesorID = 2;
GO

-- Eliminar Alquiler Por ID
CREATE PROCEDURE EliminarAlquilerPorID 
    @AlquilerID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacci�n
        BEGIN TRANSACTION;

        -- Verificar si el alquiler existe
        IF EXISTS (SELECT * FROM Alquileres WHERE Id = @AlquilerID)
        BEGIN
            DELETE FROM Alquileres WHERE Id = @AlquilerID;
            PRINT 'Alquiler eliminado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El alquiler no existe.';
        END

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC EliminarAlquilerPorID 
    @AlquilerID = 4;
GO

---------------------------------------------------------
              -- BONUS: USO DE CURSORES --
---------------------------------------------------------

--Cursor para listar clientes con sus membres�as

DECLARE @Cliente NVARCHAR(100);
DECLARE @Membresia NVARCHAR(50);


DECLARE CursorClientesMembresias CURSOR FOR
SELECT Clientes.Nombre, Membresias.Nombre
FROM Clientes
JOIN Membresias ON Clientes.Membresia = Membresias.Id;


OPEN CursorClientesMembresias;

-- Leer la primera fila
FETCH NEXT FROM CursorClientesMembresias INTO @Cliente, @Membresia;

-- Bucle para recorrer las filas del cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Cliente: ' + @Cliente + ', Membres�a: ' + @Membresia;

    -- Leer la siguiente fila
    FETCH NEXT FROM CursorClientesMembresias INTO @Cliente, @Membresia;
END;

-- Cerrar y liberar el cursor
CLOSE CursorClientesMembresias;
DEALLOCATE CursorClientesMembresias;

--Retorna
--Cliente: Juan P�rez, Membres�a: B�sica
--Cliente: Mar�a L�pez, Membres�a: Premium
--Cliente: Carlos Garc�a, Membres�a: VIP
--Cliente: Sofia P�rez, Membres�a: Premium
--Cliente: Margarita Zapata, Membres�a: B�sica

-------------------------------------------------
-------------------------------------------------

--Cursor para generar un reporte de ingresos por asesor

DECLARE @AsesorId INT;
DECLARE @NombreAsesor NVARCHAR(100);
DECLARE @Ingresos DECIMAL(10,2);

DECLARE CursorIngresosAsesor CURSOR FOR
SELECT Id, Nombre
FROM Asesores;

OPEN CursorIngresosAsesor;

FETCH NEXT FROM CursorIngresosAsesor INTO @AsesorId, @NombreAsesor;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Calcular los ingresos totales del asesor
    SELECT @Ingresos = SUM(Valor)
    FROM Alquileres
    WHERE Asesor = @AsesorId;

    -- Si no tiene ingresos, asignar 0
    IF @Ingresos IS NULL
        SET @Ingresos = 0;

    -- Imprimir los resultados
    PRINT 'Asesor: ' + @NombreAsesor + ' - Ingresos totales: $' + CAST(@Ingresos AS NVARCHAR);

    -- Leer la siguiente fila
    FETCH NEXT FROM CursorIngresosAsesor INTO @AsesorId, @NombreAsesor;
END;

CLOSE CursorIngresosAsesor;
DEALLOCATE CursorIngresosAsesor;

PRINT 'Reporte de ingresos por asesor generado.';
--Retorna
--Asesor: Pedro Castillo - Ingresos totales: $1200.00
--Asesor: Luisa Mart�nez - Ingresos totales: $950.00
--Asesor: Ana G�mez - Ingresos totales: $1000.00
--Reporte de ingresos por asesor generado.

-- :D