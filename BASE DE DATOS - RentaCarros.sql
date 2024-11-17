CREATE DATABASE db_RentaCarros
GO

USE db_RentaCarros
GO


-- Tabla Membresías
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

-- Tabla Vehículos
CREATE TABLE Vehiculos (
    Id INT PRIMARY KEY IDENTITY(1,1),
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

-- Datos para la tabla Membresías
INSERT INTO Membresias (Nombre)
VALUES ('Básica'), ('Premium'), ('VIP');

-- Datos para la tabla Clientes
INSERT INTO Clientes (Nombre, Cedula, Direccion, Edad, Membresia)
VALUES 
('Juan Pérez', '123456789', 'Calle Falsa 123', 35, 1),
('María López', '987654321', 'Avenida Principal 456', 28, 2),
('Carlos García', '654321987', 'Carrera Secundaria 789', 40, 3);

-- Datos para la tabla Vehículos
INSERT INTO Vehiculos (Tipo, Marca, Modelo, Kilometraje)
VALUES
('SUV', 'Toyota', 'RAV4', 20000),
('Sedán', 'Honda', 'Civic', 15000),
('Pickup', 'Ford', 'Ranger', 30000),
('Deportivo', 'Chevrolet', 'Camaro', 10000);

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
('Luisa Martínez', '222222222', 2),
('Ana Gómez', '333333333', 3);
GO

-- Datos para la tabla Alquileres (Uso de transaccion para veificar la consistencia de los datos ingresados)
BEGIN TRY
    -- Iniciar una transacción
    BEGIN TRANSACTION;

    -- Declaración de variables, simulacion de entrada de datos
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

    -- Verificar que el vehículo existe
    IF NOT EXISTS (SELECT 1 FROM Vehiculos WHERE Id = @VehiculoId)
    BEGIN
        PRINT 'El vehículo no existe.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    -- Registrar el alquiler en la tabla Alquileres
    INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
    VALUES (@ClienteId, @AsesorId, @FechaRenta, @FechaFinalizacion, @Valor, @VehiculoId);

    -- Confirmar la transacción
    COMMIT TRANSACTION;
    PRINT 'Alquiler registrado correctamente.';
END TRY
BEGIN CATCH
    PRINT 'Ocurrió un error: ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH;

GO

select * from alquileres
select * from vehiculos

-----------------------------------------------------
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

--Transaccion para verificar si un alquiler existe, y actualizar su fecha de finalizacion y el kilometraje añadido para el auto
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @FechaFinalizacion DATE = GETDATE();
	DECLARE @Nuevo_kilometraje DECIMAL(10,2) = 10000;
	DECLARE @IDvehiculo INT = 4;

    -- Verificar que el alquiler existe
    IF NOT EXISTS (SELECT 1 FROM Alquileres WHERE Vehiculo = @IDvehiculo AND Fecha_finalizacion IS NULL) 
    BEGIN
        PRINT 'El auto no está alquilado';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Actualizar la fecha y kilometraje dentro de la tabla de alquileres
    UPDATE Alquileres
	SET Fecha_finalizacion = @FechaFinalizacion, Nuevo_Kilometraje = @Nuevo_kilometraje
	WHERE Vehiculo = @IDvehiculo;


    -- Confirmar la transacción
    COMMIT TRANSACTION;
    PRINT '	Alquiler actualizado con exito';
END TRY
BEGIN CATCH
    PRINT 'Ocurrió un error: ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH;
GO


--C R U D

--CREATE
	--Crear tablas
CREATE TABLE Daños_Vehiculo(
	ID int primary key identity(1,1),
	Tipo_Daño NVARCHAR(100),
	Descripcion NVARCHAR(MAX)
);

	--Agregar valores a las tablas
INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
VALUES
(3, 2, '2022-12-21', NULL, 5000.00, 4);
GO
	--Crear columnas nuevas a las tablas
ALTER TABLE Alquileres
ADD Costos_adicionales decimal(10,2);


--READ (Consultas pa NATHY)










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
WHERE Cliente = 3 and Asesor = 3
--DELETE

	--Borrar tablas
DROP TABLE Daños_Vehiculo

	--Borrar columnas
ALTER TABLE Alquileres
DROP COLUMN Costos_adicionales