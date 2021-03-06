-- Mark tasks as solved when solution is provided
DROP TRIGGER IF EXISTS TASK_SOLVED;
DELIMITER |
CREATE TRIGGER TASK_SOLVED AFTER INSERT ON Solution
FOR EACH ROW
BEGIN
UPDATE Task SET solved=1 WHERE Task.bin_uuid = NEW.bin_uuid;
END; |
DELIMITER ;
-- Mark tasks as unsolved if no remaining solutions
DROP TRIGGER IF EXISTS TASK_UNSOLVED;
DELIMITER |
CREATE TRIGGER TASK_UNSOLVED AFTER DELETE ON Solution
FOR EACH ROW
BEGIN
UPDATE Task SET solved=0 WHERE Task.bin_uuid = OLD.bin_uuid 
    AND (SELECT COUNT(*) FROM Solution WHERE Solution.bin_uuid=Task.bin_uuid)=0;
END; |
DELIMITER ;
-- Create tasks for a task set
DROP TRIGGER IF EXISTS TASKSET_CREATED;
DELIMITER |
CREATE TRIGGER TASKSET_CREATED AFTER INSERT ON TaskSet
FOR EACH ROW
BEGIN
DECLARE i INT;
SET i=0;
WHILE i<NEW.task_count DO
INSERT INTO Task VALUES(BINARIZE_UUID(UUID()), NEW.bin_uuid, NULL, i, 0, NOW());

SET i = i+1;
END WHILE;
END; |
DELIMITER ;

DROP TRIGGER IF EXISTS TASKSET_DELETED;
DELIMITER |
CREATE TRIGGER TASKSET_DELETED BEFORE DELETE ON TaskSet
FOR EACH ROW
BEGIN
DELETE FROM Task WHERE taskset=OLD.bin_uuid;
END; |
DELIMITER ;