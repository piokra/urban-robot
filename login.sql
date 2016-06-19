-- Login and return session
DROP FUNCTION IF EXISTS LOGIN;
DELIMITER |
CREATE FUNCTION LOGIN(__user VARCHAR(32), __password BINARY(32), __ip VARCHAR(64))
RETURNS CHAR(36) -- returns session uuid
BEGIN
DECLARE _salt BINARY(32);
DECLARE _sha256 BINARY(32);
DECLARE _bin_usr BINARY(16);
DECLARE _mysha256 BINARY(32);
DECLARE _uuid CHAR(36);

SELECT User.bin_uuid, User.sha256, User.salt INTO _bin_usr,_sha256, _salt FROM User 
    WHERE name=__user;

SET _mysha256 = UNHEX(SHA2(CONCAT(_salt,__password),256));
IF _mysha256=_sha256 AND _sha256 IS NOT NULL THEN

	SET _uuid = UUID();
	INSERT INTO Session(bin_uuid, user, ip) VALUES(BINARIZE_UUID(_uuid), _bin_usr, __ip);
	
	RETURN _uuid;
END IF;
INSERT INTO Logger(bin_uuid, log) SELECT BINARIZE_UUID(UUID()), 
    CONCAT('FAILED_LOGIN_ATTEMPT FROM: ', __ip);
INSERT INTO Logger(bin_uuid, log) SELECT BINARIZE_UUID(UUID()), hex(_mysha256);
INSERT INTO Logger(bin_uuid, log) SELECT BINARIZE_UUID(UUID()), hex(_salt);
RETURN NULL;
END |
DELIMITER ;

DROP FUNCTION IF EXISTS CREATE_USER
DELIMITER |
CREATE FUNCTION CREATE_USER(__name VARCHAR(32), __password VARCHAR(32), __email VARCHAR(255))
RETURNS CHAR(36) -- Returns user uuid human readable
BEGIN 
DECLARE _uuid CHAR(36);
SET _uuid = UUID();
INSERT INTO User(bin_uuid,name,email,sha256) SELECT BINARIZE_UUID(_uuid), __name, __email, __password; 
RETURN _uuid;
END |
DELIMITER ;

DROP PROCEDURE IF EXISTS DELETE_USER
DELIMITER |
CREATE PROCEDURE DELETE_USER(IN __name VARCHAR(32)) -- Deletes user and all matching sessions
BEGIN
DELETE FROM Session WHERE Session.user IN (SELECT User.bin_uuid FROM User WHERE User.name=__name);
DELETE FROM User WHERE name=__name;
END |
DELIMITER ;

