/* ================================================================
   03_DCL.sql – Seguridad y Auditoría
   ================================================================ */
USE Academia2022;
GO

-- USUARIO SOLO LECTURA
IF USER_ID('app_ro') IS NOT NULL DROP USER app_ro;
CREATE USER app_ro WITHOUT LOGIN WITH DEFAULT_SCHEMA = App;
EXEC sp_addrolemember N'db_datareader', N'app_ro';
GO

-- ROL PERSONALIZADO
CREATE ROLE rol_reportes;
GRANT SELECT ON SCHEMA::App TO rol_reportes;
EXEC sp_addrolemember 'rol_reportes','app_ro';
GO

-- DENEGAR ACCESO A TABLAS BASE
DENY SELECT ON OBJECT::Academico.Alumnos TO app_ro;
GO

-- SINÓNIMO PARA COMPATIBILIDAD
CREATE SYNONYM dbo.Matriculas FOR Academico.Matriculas;
GO

-- RLS
CREATE SCHEMA Sec;
GO
CREATE FUNCTION Sec.fn_AlumnosActivos(@Activo BIT)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN SELECT 1 AS AllowRow WHERE @Activo = 1;
GO
CREATE SECURITY POLICY Sec.Policy_Alumnos
ADD FILTER PREDICATE Sec.fn_AlumnosActivos(AlumnoActivo)
ON Academico.Alumnos
WITH (STATE = ON);
GO

-- AUDITORÍA INTERNA
CREATE SCHEMA Security;
GO
CREATE TABLE Security.Audit_Permissions(
    AuditID INT IDENTITY PRIMARY KEY,
    EventTime DATETIME2 DEFAULT SYSUTCDATETIME(),
    EventType NVARCHAR(50),
    LoginName SYSNAME DEFAULT SUSER_NAME(),
    ObjectName NVARCHAR(256),
    PermissionType NVARCHAR(100),
    Success BIT,
    Details NVARCHAR(MAX)
);
GO

CREATE OR ALTER PROCEDURE Security.sp_AuditPermissionChange
    @ObjectName NVARCHAR(256),
    @PermissionType NVARCHAR(100),
    @Granted BIT,
    @Details NVARCHAR(MAX)=NULL
AS
BEGIN
    INSERT INTO Security.Audit_Permissions(EventType,ObjectName,PermissionType,Success,Details)
    VALUES('PERMISSION_CHANGE',@ObjectName,@PermissionType,@Granted,@Details);
END;
GO

CREATE OR ALTER PROCEDURE Security.sp_AuditFailedLogin
    @LoginName SYSNAME,@Details NVARCHAR(MAX)=NULL
AS
BEGIN
    INSERT INTO Security.Audit_Permissions(EventType,LoginName,Success,Details)
    VALUES('LOGIN_FAILED',@LoginName,0,@Details);
END;
GO
