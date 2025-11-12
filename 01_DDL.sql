/* ================================================================
   01_DDL.sql – Estructura base del proyecto Academia2022
   Módulo: Seguridad, Reportes y Auditoría
   ================================================================ */

-- Reiniciar base
IF DB_ID('Academia2022') IS NOT NULL
BEGIN
    ALTER DATABASE Academia2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Academia2022;
END
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
    CarreraNombre NVARCHAR(80) NOT NULL CONSTRAINT UQ_Carreras_Nombre UNIQUE
);
GO

ALTER TABLE Academico.Alumnos
ADD CarreraID INT NULL CONSTRAINT FK_Alumnos_Carreras
FOREIGN KEY (CarreraID) REFERENCES Academico.Carreras(CarreraID)
ON DELETE SET NULL;
GO

CREATE TABLE Academico.Cursos(
    CursoID INT IDENTITY(1,1) CONSTRAINT PK_Cursos PRIMARY KEY,
    CursoNombre NVARCHAR(100) NOT NULL CONSTRAINT UQ_Cursos_Nombre UNIQUE,
    CursoCreditosECTS TINYINT NOT NULL CONSTRAINT CK_Cursos_Creditos CHECK (CursoCreditosECTS BETWEEN 1 AND 10)
);
GO

CREATE TABLE Academico.Matriculas(
    AlumnoID INT NOT NULL,
    CursoID INT NOT NULL,
    MatriculaPeriodo CHAR(6) NOT NULL CONSTRAINT CK_Matriculas_Periodo CHECK (MatriculaPeriodo LIKE '[12][0-9][0-9][0-9][S][12]'),
    CONSTRAINT PK_Matriculas PRIMARY KEY (AlumnoID, CursoID, MatriculaPeriodo),
    CONSTRAINT FK_Matriculas_Alumnos FOREIGN KEY (AlumnoID) REFERENCES Academico.Alumnos(AlumnoID) ON DELETE CASCADE,
    CONSTRAINT FK_Matriculas_Cursos FOREIGN KEY (CursoID) REFERENCES Academico.Cursos(CursoID) ON DELETE CASCADE
);
GO

/* ================================================================
   COLUMNAS CALCULADAS, ÍNDICES Y SECUENCIAS
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
ALTER TABLE Academico.Alumnos
ADD ContactoID INT NULL CONSTRAINT FK_Alumnos_Contactos
FOREIGN KEY (ContactoID) REFERENCES Academico.Contactos(ContactoID);
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
   VISTAS INDEXADAS (KPIs)
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
