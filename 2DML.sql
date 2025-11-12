/* ================================================================
   02_DML.sql – Inserciones y Transacciones ACID
   Proyecto: Academia2022
   ================================================================ */

USE Academia2022;
GO

/* ================================================================
   1️⃣ Inserciones base (Catálogos principales)
   ================================================================ */

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


/* ================================================================
   2️⃣ Inserciones dependientes (Matriculas)
   ================================================================ */
-- Supone que CarreraID y CursoID existen desde las inserciones anteriores

INSERT INTO Academico.Matriculas (AlumnoID, CursoID, MatriculaPeriodo)
VALUES
(1,1,'2025S1'),
(1,2,'2025S1'),
(2,3,'2025S1'),
(2,4,'2025S2'),
(3,1,'2025S2'),
(4,2,'2025S2');
GO


/* ================================================================
   3️⃣ Ejemplo de transacción controlada
   ================================================================ */
PRINT '--- Prueba de transacción (COMMIT) ---';
BEGIN TRANSACTION;
    INSERT INTO Academico.Carreras (CarreraNombre)
    VALUES ('Ciberseguridad y Redes');
COMMIT TRANSACTION;
PRINT 'Transacción completada con éxito.';
GO


PRINT '--- Prueba de transacción (ROLLBACK) ---';
BEGIN TRANSACTION;
    INSERT INTO Academico.Carreras (CarreraNombre)
    VALUES ('Carrera Temporal para Rollback');
ROLLBACK TRANSACTION;
PRINT 'Rollback ejecutado (no se guardó la inserción).';
GO


/* ================================================================
   4️⃣ Verificación de datos insertados
   ================================================================ */
PRINT '--- Listado de registros insertados ---';
SELECT * FROM Academico.Carreras;
SELECT * FROM Academico.Cursos;
SELECT * FROM Academico.Alumnos;
SELECT * FROM Academico.Matriculas;
GO

PRINT '=== Script 02_DML.sql ejecutado correctamente ===';
GO
