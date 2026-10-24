
DROP DATABASE IF EXISTS SALUD_USM;
CREATE DATABASE SALUD_USM;
USE SALUD_USM;

CREATE TABLE Estado (
    Id_Estado INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE Especialidad (
    Id_Especialidad INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Especialidad VARCHAR(100) NOT NULL
);

CREATE TABLE Catalogo_CIE10 (
    Codigo_Cie10 VARCHAR(10) PRIMARY KEY,
    Descripcion_Cie10 VARCHAR(255) NOT NULL
);

CREATE TABLE Region (
    Id_region INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Prevision (
    Id_prevision INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Comunas (
    Id_comuna INT AUTO_INCREMENT PRIMARY KEY,
    Id_region INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FOREIGN KEY (Id_region) REFERENCES Region(Id_region) ON DELETE CASCADE
);

CREATE TABLE Medico (
    Rut_Medico VARCHAR(12) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Edad INT,
    Email VARCHAR(100)
);

CREATE TABLE Centro_Medico (
    Id_Centro_Medico INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200),
    Id_comuna INT,
    FOREIGN KEY (Id_comuna) REFERENCES Comunas(Id_comuna) ON DELETE SET NULL
);

CREATE TABLE Paciente (
    Rut_Paciente VARCHAR(12) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Sexo CHAR(1),
    Fecha_Nacimiento DATE,
    Telefono_contacto VARCHAR(15),
    Id_comuna INT,
    Id_prevision INT,
    FOREIGN KEY (Id_comuna) REFERENCES Comunas(Id_comuna) ON DELETE SET NULL,
    FOREIGN KEY (Id_prevision) REFERENCES Prevision(Id_prevision) ON DELETE SET NULL
);

CREATE TABLE Medico_Centro (
    Rut_Medico VARCHAR(12),
    Id_Centro_Medico INT,
    PRIMARY KEY (Rut_Medico, Id_Centro_Medico),
    FOREIGN KEY (Rut_Medico) REFERENCES Medico(Rut_Medico) ON DELETE CASCADE,
    FOREIGN KEY (Id_Centro_Medico) REFERENCES Centro_Medico(Id_Centro_Medico) ON DELETE CASCADE
);

CREATE TABLE Especialidad_Medico (
    Rut_Medico VARCHAR(12),
    Id_Especialidad INT,
    PRIMARY KEY (Rut_Medico, Id_Especialidad),
    FOREIGN KEY (Rut_Medico) REFERENCES Medico(Rut_Medico) ON DELETE CASCADE,
    FOREIGN KEY (Id_Especialidad) REFERENCES Especialidad(Id_Especialidad) ON DELETE CASCADE
);

CREATE TABLE Cita (
    Id_Cita INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Rut_Medico VARCHAR(12) NOT NULL,
    Rut_Paciente VARCHAR(12) NOT NULL,
    Id_Centro_Medico INT NOT NULL,
    Id_Estado INT NOT NULL,
    Id_Especialidad INT NOT NULL,
    FOREIGN KEY (Rut_Medico) REFERENCES Medico(Rut_Medico) ON DELETE CASCADE,
    FOREIGN KEY (Rut_Paciente) REFERENCES Paciente(Rut_Paciente) ON DELETE CASCADE,
    FOREIGN KEY (Id_Centro_Medico) REFERENCES Centro_Medico(Id_Centro_Medico) ON DELETE CASCADE,
    FOREIGN KEY (Id_Estado) REFERENCES Estado(Id_Estado) ON DELETE CASCADE,
    FOREIGN KEY (Id_Especialidad) REFERENCES Especialidad(Id_Especialidad) ON DELETE CASCADE
);

CREATE TABLE Atencion (
    Id_Atencion INT AUTO_INCREMENT PRIMARY KEY,
    Id_Cita INT NOT NULL,
    Motivo_Consulta TEXT NOT NULL,
    Observaciones TEXT,
    FOREIGN KEY (Id_Cita) REFERENCES Cita(Id_Cita) ON DELETE CASCADE
);

CREATE TABLE Diagnostico (
    Id_Diagnostico INT AUTO_INCREMENT PRIMARY KEY,
    Id_Atencion INT NOT NULL,
    Codigo_Cie10 VARCHAR(10) NOT NULL,
    Observaciones TEXT,
    FOREIGN KEY (Id_Atencion) REFERENCES Atencion(Id_Atencion) ON DELETE CASCADE,
    FOREIGN KEY (Codigo_Cie10) REFERENCES Catalogo_CIE10(Codigo_Cie10) ON DELETE CASCADE
);

CREATE TABLE Receta (
    Id_Receta INT AUTO_INCREMENT PRIMARY KEY,
    Id_Atencion INT NOT NULL,
    Medicamento VARCHAR(100) NOT NULL,
    Dosis VARCHAR(100) NOT NULL,
    Dias_Tratamiento INT NOT NULL,
    FOREIGN KEY (Id_Atencion) REFERENCES Atencion(Id_Atencion) ON DELETE CASCADE
);

--este es el trigger
DELIMITER //

CREATE TRIGGER trg_evitar_choque_citas_paciente
BEFORE INSERT ON Cita
FOR EACH ROW
BEGIN
    DECLARE citas_existentes INT;
    
    SELECT COUNT(*) INTO citas_existentes
    FROM Cita
    WHERE Rut_Paciente = NEW.Rut_Paciente 
        AND Fecha = NEW.Fecha 
        AND Hora = NEW.Hora
        AND Id_Estado IN (1, 2);
    
    IF citas_existentes > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El paciente ya tiene una cita agendada en esta fecha y hora.';
    END IF;
END //

DELIMITER ;


--el Login
ALTER TABLE Paciente ADD COLUMN Email VARCHAR(100);
ALTER TABLE Paciente ADD COLUMN Password VARCHAR(255) NOT NULL;
ALTER TABLE Medico ADD COLUMN Password VARCHAR(255) NOT NULL DEFAULT '123456';

CREATE TABLE Admin (
    Rut_Admin VARCHAR(12) PRIMARY KEY, Password VARCHAR(255) NOT NULL
    );

INSERT INTO Admin (Rut_Admin, Password) VALUES ('11111111-1', 'admin123');