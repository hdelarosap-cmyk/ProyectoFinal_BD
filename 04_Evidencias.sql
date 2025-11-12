/* ================================================================
   04_Evidencias.sql – Validaciones y Evidencias del Proyecto Academia2022
   ================================================================ */
USE Academia2022;
GO

/* ================================================================
   1️⃣ Verificar relación ON DELETE SET NULL (Carreras → Alumnos)
   ================================================================ */
PRINT '--- [1] Prueba ON DELETE SET NULL ---';
DELETE FROM Academico.Carreras WHERE CarreraID = 1;
SELECT AlumnoID, AlumnoNombre, CarreraID 
FROM Academico.Alumnos;
GO

/* ================================================================
   2️⃣ Verificar ON DELETE CASCADE (Alumnos → Matriculas)
   ================================================================ */
PRINT '--- [2] Prueba ON DELETE CASCADE ---';
DELETE FROM Academico.Alumnos WHERE AlumnoID = 2;
SELECT * 
FROM Academico.Matriculas 
WHERE AlumnoID = 2;
GO

/* ================================================================
   3️⃣ Verificar CHECK de formato en MatriculaPeriodo
   ================================================================ */
PRINT '--- [3] Prueba de restricción CHECK en MatriculaPeriodo ---';

-- Caso inválido 1: formato corto (debe fallar)
BEGIN TRY
    INSERT INTO Academico.Matriculas VALUES (4,3,'2559');
END TRY
BEGIN CATCH
    PRINT 'Error (caso 1): ' + ERROR_MESSAGE();
END CATCH;

-- Caso inválido 2: formato incorrecto
BEGIN TRY
    INSERT INTO Academico.Matriculas VALUES (4,3,'202S3');
END TRY
BEGIN CATCH
    PRINT 'Error (caso 2): ' + ERROR_MESSAGE();
END CATCH;

-- Caso válido
BEGIN TRY
    INSERT INTO Academico.Matriculas VALUES (4,3,'2025S1');
    PRINT 'Caso válido insertado correctamente (2025S1)';
END TRY
BEGIN CATCH
    PRINT 'Error (caso válido): ' + ERROR_MESSAGE();
END CATCH;
GO

/* ================================================================
   4️⃣ Consultar vistas indexadas (KPIs)
   ================================================================ */
PRINT '--- [4] Consultar vistas indexadas ---';
SELECT * FROM App.vw_MatriculasPorCurso;
SELECT * FROM App.vw_CargaPorAlumno;
SELECT * FROM App.vw_OcupacionPorPeriodo;
GO

/* ================================================================
   5️⃣ Auditoría simulada
   ================================================================ */
PRINT '--- [5] Prueba de Auditoría ---';
EXEC Security.sp_AuditPermissionChange 
    @ObjectName='Academico.Cursos',
    @PermissionType='SELECT',
    @Granted=1,
    @Details='Simulación auditoría';
GO

EXEC Security.sp_AuditFailedLogin 
    @LoginName='app_ro',
    @Details='Intento fallido';
GO

SELECT TOP 10 *
FROM Security.Audit_Permissions
ORDER BY AuditID DESC;
GO

/* ================================================================
   6️⃣ Verificación de Row-Level Security (RLS)
   ================================================================ */
PRINT '--- [6] Prueba de Row-Level Security (solo alumnos activos visibles) ---';
EXECUTE AS USER = 'app_ro';
SELECT AlumnoID, AlumnoNombre, AlumnoActivo
FROM Academico.Alumnos;
REVERT;
GO

/* ================================================================
   7️⃣ Resumen general (conteos de evidencia)
   ================================================================ */
PRINT '--- [7] Resumen General ---';
SELECT 
    (SELECT COUNT(*) FROM Academico.Alumnos) AS TotalAlumnos,
    (SELECT COUNT(*) FROM Academico.Matriculas) AS TotalMatriculas,
    (SELECT COUNT(*) FROM Academico.Carreras) AS TotalCarreras,
    (SELECT COUNT(*) FROM Security.Audit_Permissions) AS TotalEventosAuditoria;
GO

PRINT '=== Script 04_Evidencias.sql ejecutado correctamente ===';
