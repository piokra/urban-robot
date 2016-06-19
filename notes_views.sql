-- Procedure that selects all random notes. Note: Views appear to be more convenient.
DROP PROCEDURE IF EXISTS SELECT_ALL_RANDOM_NOTES;
DELIMITER | 
CREATE PROCEDURE SELECT_ALL_RANDOM_NOTES()
BEGIN
SELECT Note.bin_uuid FROM Note
LEFT OUTER JOIN Task on Note.bin_uuid = Task.note
LEFT OUTER JOIN Solution on Note.bin_uuid = Solution.note
WHERE Task.note IS NULL AND Solution.note IS NULL;
END |
DELIMITER ;

DROP VIEW IF EXISTS ALL_RANDOM_NOTES;
CREATE VIEW ALL_RANDOM_NOTES AS 
SELECT Note.bin_uuid AS BUUID, UNBINARIZE_UUID(Note.bin_uuid) as UUID FROM Note
LEFT OUTER JOIN Task on Note.bin_uuid = Task.note
LEFT OUTER JOIN Solution on Note.bin_uuid = Solution.note
WHERE Task.note IS NULL AND Solution.note IS NULL;

DROP VIEW IF 