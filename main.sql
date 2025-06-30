-- =============================================================================
-- SUBJECT ALLOTMENT TRACKING SYSTEM - STORED PROCEDURE AND EXAMPLE USAGE
-- =============================================================================

-- Drop the existing procedure if it exists
IF OBJECT_ID('dbo.ProcessSubjectRequests', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcessSubjectRequests;
GO

-- Create the SubjectAllotments table if it doesn't exist
IF OBJECT_ID('dbo.SubjectAllotments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SubjectAllotments (
        StudentId VARCHAR(50),
        SubjectId VARCHAR(50),
        Is_Valid BIT
    );
END
GO

-- Create the SubjectRequest table if it doesn't exist
IF OBJECT_ID('dbo.SubjectRequest', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SubjectRequest (
        StudentId VARCHAR(50),
        SubjectId VARCHAR(50)
    );
END
GO

-- ---------------------------------------------------------------------
-- OPTIONAL: Insert sample data matching the question's example
-- This section clears old test data for StudentId '159103036'
-- ---------------------------------------------------------------------
DELETE FROM dbo.SubjectAllotments WHERE StudentId = '159103036';
DELETE FROM dbo.SubjectRequest WHERE StudentId = '159103036';

-- Insert example subject history for the student
INSERT INTO dbo.SubjectAllotments (StudentId, SubjectId, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Insert a new subject request for the student
INSERT INTO dbo.SubjectRequest (StudentId, SubjectId) VALUES
('159103036', 'PO1496');
GO

-- =============================================================================
-- Stored Procedure: ProcessSubjectRequests
-- Description:
--   - Reads SubjectRequest table.
--   - For each student, checks current active subject.
--   - If requested subject is different, updates history and inserts new active.
--   - If student is new, simply inserts the request as active.
-- =============================================================================
CREATE PROCEDURE dbo.ProcessSubjectRequests
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StudentId VARCHAR(50),
        @RequestedSubjectId VARCHAR(50),
        @CurrentSubjectId VARCHAR(50);

    DECLARE request_cursor CURSOR FOR
        SELECT StudentId, SubjectId FROM dbo.SubjectRequest;

    OPEN request_cursor;

    FETCH NEXT FROM request_cursor INTO @StudentId, @RequestedSubjectId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check current active subject for this student
        SELECT TOP 1 @CurrentSubjectId = SubjectId
        FROM dbo.SubjectAllotments
        WHERE StudentId = @StudentId AND Is_Valid = 1;

        -- If no active record exists, simply insert as new active
        IF @CurrentSubjectId IS NULL
        BEGIN
            INSERT INTO dbo.SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @RequestedSubjectId, 1);
        END
        -- If the requested subject is different, update history and insert new
        ELSE IF @CurrentSubjectId <> @RequestedSubjectId
        BEGIN
            UPDATE dbo.SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentId = @StudentId AND Is_Valid = 1;

            INSERT INTO dbo.SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @RequestedSubjectId, 1);
        END
        -- Else: the requested subject is already active; do nothing

        FETCH NEXT FROM request_cursor INTO @StudentId, @RequestedSubjectId;
    END

    CLOSE request_cursor;
    DEALLOCATE request_cursor;

    -- Optionally clear the SubjectRequest table after processing
    -- TRUNCATE TABLE dbo.SubjectRequest;
END;
GO

-- =============================================================================
-- Execute the procedure to process all current subject requests
-- =============================================================================
EXEC dbo.ProcessSubjectRequests;
GO

-- =============================================================================
-- View the final state of the SubjectAllotments table
-- Should show the requested subject as active (Is_Valid = 1)
-- and all previous subjects as inactive (Is_Valid = 0)
-- =============================================================================
SELECT * 
FROM dbo.SubjectAllotments
WHERE StudentId = '159103036'
ORDER BY Is_Valid DESC, SubjectId;
GO
