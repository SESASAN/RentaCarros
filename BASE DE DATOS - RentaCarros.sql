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
    Fecha_finalizacion DATE NOT NULL,
    Valor DECIMAL(10,2),
    Vehiculo INT NOT NULL,
    CONSTRAINT FK_Alquileres_Clientes FOREIGN KEY (Cliente) REFERENCES Clientes(Id),
    CONSTRAINT FK_Alquileres_Asesores FOREIGN KEY (Asesor) REFERENCES Asesores(Id),
    CONSTRAINT FK_Alquileres_Vehiculos FOREIGN KEY (Vehiculo) REFERENCES Vehiculos(Id)
);
GO

-- Datos para la tabla Membresías
INSERT INTO Membresias (Nombre)
VALUES ('Básica'), ('Premium'), ('VIP');
GO

-- Datos para la tabla Clientes
INSERT INTO Clientes (Nombre, Cedula, Direccion, Edad, Membresia)
VALUES 
('Juan Pérez', '123456789', 'Calle Falsa 123', 35, 1),
('María López', '987654321', 'Avenida Principal 456', 28, 2),
('Carlos García', '654321987', 'Carrera Secundaria 789', 40, 3);
GO

-- Datos para la tabla Vehículos
INSERT INTO Vehiculos (Tipo, Marca, Modelo, Kilometraje, Disponibilidad)
VALUES
('SUV', 'Toyota', 'RAV4', 20000, 1),
('Sedán', 'Honda', 'Civic', 15000, 1),
('Pickup', 'Ford', 'Ranger', 30000, 0),
('Deportivo', 'Chevrolet', 'Camaro', 10000, 1);
GO

-- Datos para la tabla Sedes
INSERT INTO Sedes (Direccion, Nombre)
VALUES
('Calle 1 #10-20', 'Sede Central'),
('Carrera 2 #15-30', 'Sede Norte'),
('Avenida 3 #20-40', 'Sede Sur');
GO

-- Datos para la tabla Asesores
INSERT INTO Asesores (Nombre, Cedula, Sede)
VALUES
('Pedro Castillo', '111111111', 1),
('Luisa Martínez', '222222222', 2),
('Ana Gómez', '333333333', 3);
GO

-- Datos para la tabla Alquileres
INSERT INTO Alquileres (Cliente, Asesor, Fecha_renta, Fecha_finalizacion, Valor, Vehiculo)
VALUES
(1, 1, '2024-11-01', '2024-11-10', 500.00, 1),
(2, 2, '2024-11-05', '2024-11-12', 700.00, 2),
(3, 3, '2024-11-08', '2024-11-15', 1000.00, 4);
GO
