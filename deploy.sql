/* ================================================================
   01_DDL.sql – Estructura base del proyecto Academia2022
   Módulo: Seguridad, Reportes y Auditoría
   ================================================================ */

-- Reiniciar base
IF DB_ID('Academia2022') IS NOT NULL
BEGIN
    ALTER DATABASE Academia2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Academia2022;
END;
GO

CREATE DATABASE Academia2022;
GO
USE Academia2022;
GO

/* ================================================================
   ESQUEMAS BASE
   ================================================================ */
CREATE SCHEMA Academico;
CREATE SCHEMA Seguridad;
CREATE SCHEMA App;
CREATE SCHEMA Lab;
GO

/* ================================================================
   TABLAS PRINCIPALES
   ================================================================ */
CREATE TABLE Academico.Alumnos(
    AlumnoID INT IDENTITY(1,1) CONSTRAINT PK_Alumnos PRIMARY KEY,
    AlumnoNombre NVARCHAR(60) NOT NULL,
    AlumnoApellido NVARCHAR(60) NOT NULL,
    AlumnoEmail NVARCHAR(120) NULL CONSTRAINT UQ_Alumnos_Email UNIQUE,
    AlumnoEdad TINYINT NOT NULL CONSTRAINT CK_Alumno_Edad CHECK (AlumnoEdad >= 16),
    AlumnoActivo BIT NOT NULL CONSTRAINT DF_Alumno_Activo DEFAULT (1)
);
GO

CREATE TABLE Academico.Carreras(
    CarreraID INT IDENTITY(1,1) CONSTRAINT PK_Carreras PRIMARY KEY,
    CarreraNombre NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Academico.Cursos(
    CursoID INT IDENTITY(1,1) CONSTRAINT PK_Cursos PRIMARY KEY,
    CursoNombre NVARCHAR(100) NOT NULL,
    CursoCreditosECTS INT NOT NULL
);
GO

CREATE TABLE Academico.Matriculas(
    MatriculaID INT IDENTITY(1,1) CONSTRAINT PK_Matriculas PRIMARY KEY,
    AlumnoID INT NOT NULL,
    CursoID INT NOT NULL,
    MatriculaPeriodo NVARCHAR(10) NOT NULL,
    CONSTRAINT FK_Matriculas_Alumnos FOREIGN KEY (AlumnoID) REFERENCES Academico.Alumnos(AlumnoID) ON DELETE CASCADE,
    CONSTRAINT FK_Matriculas_Cursos FOREIGN KEY (CursoID) REFERENCES Academico.Cursos(CursoID) ON DELETE CASCADE
);
GO

/* ================================================================
   COLUMNAS CALCULADAS, SECUENCIAS E ÍNDICES
   ================================================================ */
ALTER TABLE Academico.Alumnos
ADD NombreCompleto AS (AlumnoNombre + N' ' + AlumnoApellido) PERSISTED;
CREATE INDEX IX_Alumnos_NombreCompleto ON Academico.Alumnos(NombreCompleto);
GO

CREATE SEQUENCE Academico.SeqCodigoCurso AS INT START WITH 1000 INCREMENT BY 1;
ALTER TABLE Academico.Cursos
ADD CursoCodigo INT NOT NULL CONSTRAINT DF_Cursos_CursoCodigo DEFAULT (NEXT VALUE FOR Academico.SeqCodigoCurso);
GO

CREATE INDEX IX_Matriculas_CursosPeriodo ON Academico.Matriculas(CursoID, MatriculaPeriodo) INCLUDE (AlumnoID);
GO

/* ================================================================
   NORMALIZACIÓN Y DATOS COMPLEMENTARIOS
   ================================================================ */
CREATE TABLE Academico.Contactos(
    ContactoID INT IDENTITY(1,1) CONSTRAINT PK_Contactos PRIMARY KEY,
    Email NVARCHAR(120) NULL CONSTRAINT UQ_Contactos_Email UNIQUE,
    Telefono VARCHAR(20) NULL
);
GO

ALTER TABLE Academico.Alumnos
ADD ContactoID INT NULL CONSTRAINT FK_Alumnos_Contactos FOREIGN KEY (ContactoID) REFERENCES Academico.Contactos(ContactoID);
GO

CREATE TABLE Academico.AlumnoIdiomas(
    AlumnoID INT NOT NULL,
    Idioma NVARCHAR(40) NOT NULL,
    Nivel NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_AlumnoIdiomas PRIMARY KEY (AlumnoID, Idioma),
    CONSTRAINT FK_AI_Alumno FOREIGN KEY (AlumnoID) REFERENCES Academico.Alumnos(AlumnoID) ON DELETE CASCADE
);
GO

/* ================================================================
   VISTAS INDEXADAS (KPI)
   ================================================================ */
CREATE VIEW App.vw_MatriculasPorCurso
WITH SCHEMABINDING
AS
SELECT m.CursoID, COUNT_BIG(*) AS Total
FROM Academico.Matriculas AS m
GROUP BY m.CursoID;
GO
CREATE UNIQUE CLUSTERED INDEX IX_vw_MatriculasPorCurso ON App.vw_MatriculasPorCurso(CursoID);
GO

CREATE VIEW App.vw_CargaPorAlumno
WITH SCHEMABINDING
AS
SELECT m.AlumnoID, m.MatriculaPeriodo, COUNT_BIG(*) AS TotalCursos
FROM Academico.Matriculas AS m
GROUP BY m.AlumnoID, m.MatriculaPeriodo;
GO
CREATE UNIQUE CLUSTERED INDEX IX_vw_CargaPorAlumno ON App.vw_CargaPorAlumno(AlumnoID, MatriculaPeriodo);
GO

CREATE VIEW App.vw_OcupacionPorPeriodo
WITH SCHEMABINDING
AS
SELECT m.MatriculaPeriodo, COUNT_BIG(*) AS TotalMatriculas
FROM Academico.Matriculas AS m
GROUP BY m.MatriculaPeriodo;
GO
CREATE UNIQUE CLUSTERED INDEX IX_vw_OcupacionPorPeriodo ON App.vw_OcupacionPorPeriodo(MatriculaPeriodo);
GO

PRINT '=== Script 01_DDL.sql ejecutado correctamente ===';
GO
/* ================================================================
   02_DML.sql – Inserciones y Transacciones ACID
   Proyecto: Academia2022
   ================================================================ */

USE Academia2022;
GO

-- CARRERAS
INSERT INTO Academico.Carreras (CarreraNombre)
VALUES 
('Ingeniería de Software'),
('Administración de Empresas'),
('Diseño Gráfico'),
('Ciencias de Datos');
GO

-- CURSOS
INSERT INTO Academico.Cursos (CursoNombre, CursoCreditosECTS)
VALUES 
('Programación Web',6),
('Base de Datos',4),
('Análisis de Datos',5),
('Marketing Digital',3),
('Diseño UX/UI',4),
('Machine Learning',6),
('SQL Avanzado',3),
('Big Data',6);
GO

-- ALUMNOS
INSERT INTO Academico.Alumnos (AlumnoNombre, AlumnoApellido, AlumnoEmail, AlumnoEdad, AlumnoActivo)
VALUES
('Juan','Pérez','juan.perez@academia.com',20,1),
('María','García','maria.garcia@academia.com',22,1),
('Carlos','López','carlos.lopez@academia.com',19,0),
('Ana','Martínez','ana.martinez@academia.com',21,1);
GO

-- CONTACTOS
INSERT INTO Academico.Contactos (Email,Telefono)
VALUES
('contacto1@academia.com','5551-0011'),
('contacto2@academia.com','5551-0012'),
('contacto3@academia.com','5551-0013'),
('contacto4@academia.com','5551-0014');
GO

-- MATRICULAS
INSERT INTO Academico.Matriculas (AlumnoID, CursoID, MatriculaPeriodo)
VALUES
(1,1,'2025S1'),
(1,2,'2025S1'),
(2,3,'2025S1'),
(2,4,'2025S2'),
(3,1,'2025S2'),
(4,2,'2025S2');
GO

-- TRANSACCIÓN COMMIT
BEGIN TRANSACTION;
    INSERT INTO Academico.Carreras (CarreraNombre)
    VALUES ('Ciberseguridad y Redes');
COMMIT TRANSACTION;
GO

-- TRANSACCIÓN ROLLBACK
BEGIN TRANSACTION;
    INSERT INTO Academico.Carreras (CarreraNombre)
    VALUES ('Carrera Temporal para Rollback');
ROLLBACK TRANSACTION;
GO

-- VERIFICACIÓN
SELECT * FROM Academico.Carreras;
SELECT * FROM Academico.Cursos;
SELECT * FROM Academico.Alumnos;
SELECT * FROM Academico.Matriculas;
GO

PRINT '=== Script 02_DML.sql ejecutado correctamente ===';
GO


/* ================================================================
   03_DCL.sql – Seguridad, Roles y Auditoría
   Proyecto: Academia2022
   ================================================================ */

USE Academia2022;
GO

-- LIMPIEZA
IF EXISTS (SELECT * FROM sys.database_principals WHERE name='usuarioAcademico')
    DROP USER usuarioAcademico;
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name='usuarioAcademico')
    DROP LOGIN usuarioAcademico;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name='rolLecturaAcademico')
    DROP ROLE rolLecturaAcademico;
GO

-- CREAR LOGIN Y USUARIO
CREATE LOGIN usuarioAcademico WITH PASSWORD='Academia2022#';
CREATE USER usuarioAcademico FOR LOGIN usuarioAcademico;
GO

-- CREAR ROL DE LECTURA
CREATE ROLE rolLecturaAcademico;
GRANT SELECT ON SCHEMA::Academico TO rolLecturaAcademico;
DENY INSERT, UPDATE, DELETE ON SCHEMA::Academico TO rolLecturaAcademico;
ALTER ROLE rolLecturaAcademico ADD MEMBER usuarioAcademico;
GO

-- FUNCIÓN DE FILTRO (RLS)
CREATE OR ALTER FUNCTION Seguridad.fn_FiltroAlumno(@AlumnoID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS Permitir
WHERE @AlumnoID = CAST(SESSION_CONTEXT(N'AlumnoID') AS INT);
GO

-- POLÍTICA RLS
CREATE SECURITY POLICY Seguridad.PoliticaRLS_Alumnos
ADD FILTER PREDICATE Seguridad.fn_FiltroAlumno(AlumnoID)
ON Academico.Alumnos
WITH (STATE = ON);
GO

-- AUDITORÍA
CREATE TABLE Seguridad.BitacoraLecturas(
    BitacoraID INT IDENTITY(1,1) PRIMARY KEY,
    Usuario NVARCHAR(100),
    FechaHora DATETIME DEFAULT GETDATE(),
    ObjetoAccedido NVARCHAR(200)
);
GO

CREATE OR ALTER PROCEDURE Seguridad.usp_RegistrarLectura
    @Objeto NVARCHAR(200)
AS
BEGIN
    INSERT INTO Seguridad.BitacoraLecturas(Usuario,ObjetoAccedido)
    VALUES (SUSER_SNAME(), @Objeto);
END;
GO

EXEC Seguridad.usp_RegistrarLectura @Objeto='Academico.Alumnos';
GO

PRINT '=== Script 03_DCL.sql ejecutado correctamente ===';
GO

/* ================================================================
   04_Evidencias.sql – Validación técnica y defensa del proyecto
   Proyecto: Academia2022
   ================================================================ */

USE Academia2022;
GO

-- TABLAS Y COLUMNAS
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='Academico';
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Alumnos';
GO

-- ÍNDICES Y COLUMNAS CALCULADAS
SELECT s.name AS SchemaName, t.name AS TableName, i.name AS IndexName
FROM sys.indexes i
JOIN sys.tables t ON i.object_id=t.object_id
JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE i.is_primary_key=0 AND i.type_desc<>'HEAP';
GO

-- VISTAS INDEXADAS
SELECT v.name AS Vista, i.name AS Indice FROM sys.views v
LEFT JOIN sys.indexes i ON v.object_id=i.object_id WHERE SCHEMA_NAME(v.schema_id)='App';
GO

-- FUNCIONES Y POLÍTICAS
SELECT SCHEMA_NAME(o.schema_id) AS Esquema, o.name AS Funcion FROM sys.objects o
WHERE o.type IN ('IF','FN','TF') AND SCHEMA_NAME(o.schema_id)='Seguridad';
GO
SELECT name,is_enabled FROM sys.security_policies;
GO

-- BITÁCORA
SELECT * FROM Seguridad.BitacoraLecturas;
GO

-- RESUMEN FINAL
SELECT 'Tablas' AS Tipo, COUNT(*) AS Cantidad FROM sys.tables
UNION ALL SELECT 'Vistas', COUNT(*) FROM sys.views
UNION ALL SELECT 'Funciones', COUNT(*) FROM sys.objects WHERE type IN('FN','TF','IF')
UNION ALL SELECT 'Índices', COUNT(*) FROM sys.indexes WHERE type_desc<>'HEAP'
UNION ALL SELECT 'Políticas RLS', COUNT(*) FROM sys.security_policies;
GO

PRINT '=== Validación completada con éxito ===';
GO
