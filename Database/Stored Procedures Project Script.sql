USE bookstore;

DELIMITER //

# Helper private procedures

CREATE PROCEDURE `is_manager` (IN idIn INT)
BEGIN
	IF (SELECT NOT EXISTS(SELECT * FROM Managers WHERE id = idIn)) THEN
			SET idIn = 0;
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'User is not a registered manager';
        END IF;
END//

CREATE PROCEDURE `init_cart` (
	IN user_idIn INT,
    OUT cart_idOUT INT
)
BEGIN
	INSERT INTO Carts (user_id)
    VALUES (user_idIn);
    
    SET cart_idOUT = LAST_INSERT_ID();
END//


# Registration procedures

CREATE PROCEDURE `register_user` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	INSERT INTO Users (username, password, last_name, first_name, email, phone, shipping_address)
    VALUES (usernameIn, passwordIn, last_nameIn, first_nameIn, emailIn, phoneIn, shipping_addressIn);
    
    SET user_idOUT = (SELECT LAST_INSERT_ID());
    
    CALL init_cart(user_idOUT, cart_idOUT);
END//

CREATE PROCEDURE `register_manager` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	INSERT INTO Users (username, password, last_name, first_name, email, phone, shipping_address)
    VALUES (usernameIn, passwordIn, last_nameIn, first_nameIn, emailIn, phoneIn, shipping_addressIn);
    
    SET user_idOUT = (SELECT LAST_INSERT_ID());
    
    CALL init_cart(user_idOUT, cart_idOUT);
END//


# Login procedures

CREATE PROCEDURE `login_manager_by_username` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE username = usernameIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_idOUT = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL is_manager(user_idOUT);
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_manager_by_email` (
	IN emailIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE email = emailIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE email = emailIn;
        IF passwordIn <> realPassword THEN
			SET user_idOUT = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL is_manager(user_idOUT);
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_user_by_email` (
	IN emailIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE email = emailIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE email = emailIn;
        IF passwordIn <> realPassword THEN
			SET user_idOUT = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;
        
        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

CREATE PROCEDURE `login_user_by_username` (
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    OUT user_idOUT INT,
    OUT cart_idOUT INT
)
BEGIN
	DECLARE realPassword CHAR(64);
    
    IF (SELECT EXISTS(
			SELECT user_id, password
			FROM Users u
			WHERE username = usernameIn
	)) THEN
		SELECT user_id, password
        INTO user_idOUT, realPassword
		FROM Users u
		WHERE username = usernameIn;
        IF passwordIn <> realPassword THEN
			SET user_idOUT = 0;			
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid username or password';
		END IF;

        CALL init_cart(user_idOUT, cart_idOUT);
    END IF;
END//

# User promotion procedures

CREATE PROCEDURE `promote_user_by_id` (IN idIn INT)
BEGIN
	INSERT INTO Managers (id)
    VALUES (idIn);
END//

CREATE PROCEDURE `promote_user_by_email` (IN emailIn VARCHAR(45))
BEGIN
	DECLARE idIn INT;
    SET idIn = (SELECT user_id FROM Users WHERE email = emailIn);
    
	INSERT INTO Managers (id)
    VALUES (idIn);
END//

CREATE PROCEDURE `promote_user_by_username` (IN usernameIn VARCHAR(45))
BEGIN
	DECLARE idIn INT;
    SET idIn = (SELECT user_id FROM Users WHERE username = usernameIn);
    
	INSERT INTO Managers (id)
    VALUES (idIn);
END//


# Manager administration procedures

CREATE PROCEDURE `add_book` (
	IN ISBNIn VARCHAR(25),
    IN titleIn VARCHAR(60),
    IN publisher_idIn INT,
    IN publication_yearIn DATE,
    IN priceIn DECIMAL,
    IN quantityIn INT,
    IN minimum_thresholdIn INT,
    IN category_idIn INT
)
BEGIN
	INSERT INTO Books (ISBN, title, publisher_id, publication_year, price, quantity, minimum_threshold, category_id)
    VALUES (ISBNIn, titleIn, publisher_idIn, publication_yearIn, priceIn, quantityIn, minimum_thresholdIn, category_idIn);
END//

CREATE PROCEDURE `modify_book` (
	IN oldISBN VARCHAR(25),
	IN ISBNIn VARCHAR(25),
    IN titleIn VARCHAR(60),
    IN publisher_idIn INT,
    IN publication_yearIn DATE,
    IN priceIn DECIMAL,
    IN quantityIn INT,
    IN minimum_thresholdIn INT,
    IN category_idIn INT
)
BEGIN
	IF oldISBN = ISBNIn THEN
		UPDATE Books
		SET
			title = titleIn,
			publisher_id = publisher_idIn,
			publication_year = publication_yearIn,
			price = priceIn,
			quantity = quantityIn,
			minimum_threshold = minimum_thresholdIn,
			category_id = category_idIn
		WHERE ISBN = oldISBN;
	ELSE 
		UPDATE Books
		SET
			ISBN = ISBNIn,
			title = titleIn,
			publisher_id = publisher_idIn,
			publication_year = publication_yearIn,
			price = priceIn,
			quantity = quantityIn,
			minimum_threshold = minimum_thresholdIn,
			category_id = category_idIn
		WHERE ISBN = oldISBN;
	END IF;
END//

# Deleted
#
# CREATE PROCEDURE `confirm_order` (IN order_idIn INT)
# BEGIN
# 	IF (SELECT EXISTS(SELECT * FROM Mng_Order WHERE order_id = order_idIn)) THEN
# 		UPDATE Mng_Order
#         SET confirmation = TRUE
#         WHERE order_id = order_idIn;
# 	ELSE
#     SIGNAL SQLSTATE '45000'
#     SET MESSAGE_TEXT = 'Order id not found in database';
#     END IF;
# END//

CREATE PROCEDURE `order_books_from_publisher` (
    IN quantityIn INT,
    IN publisher_idIn INT,
    IN ISBNIn VARCHAR(25),
    OUT order_id INT
)
BEGIN
	INSERT INTO Mng_Order (quantity, publisher_id, ISBN)
    VALUES (quantityIn, publisher_idIn, ISBNIn);
    
    SET order_id = (SELECT LAST_INSERT_ID());
END//


# User functionalities procedures

CREATE PROCEDURE `update_user_info` (
	IN user_idiN INT,
	IN usernameIn VARCHAR(45),
    IN passwordIn CHAR(64),
    IN last_nameIn VARCHAR(45),
    IN first_nameIn VARCHAR(45),
    IN emailIn VARCHAR(45),
    IN phoneIn VARCHAR(13),
    IN shipping_addressIn VARCHAR(50)
)
BEGIN
	UPDATE Users
    SET
		username = usernameIn,
        password = passwordIn,
        last_name = last_nameIn,
        first_name = first_nameIn,
        email = emailIn, 
        phone = phoneIn, 
        shipping_address = shipping_addressIn
	WHERE user_id = user_idIn;
END//

# Cart management

CREATE PROCEDURE `cart_include_book` (
	IN cart_idIn INT,
    IN ISBNIn VARCHAR(25),
    IN quantityIn INT
)
BEGIN
	IF (SELECT EXISTS(SELECT * FROM Cart_Items WHERE cart_id = cart_idIn AND ISBN = ISBNIn)) THEN
		UPDATE Cart_Items
        SET quantity = quantityIn
        WHERE  cart_id = cart_idIn AND ISBN = ISBNIn;
	ELSE
		INSERT INTO Cart_Items (cart_id, ISBN, quantity, price)
        VALUES (cart_idIn, ISBNIn, quantityIn, (SELECT price FROM Books WHERE ISBN = ISBNIn));
    END IF;
END//

CREATE PROCEDURE `view_cart` (IN cart_idIn INT)
BEGIN
	SELECT *
    FROM Cart_Items
    WHERE cart_id = cart_idIn;
END//

CREATE PROCEDURE `cart_exclude_book` (
	IN cart_idIn INT,
    IN ISBNIn VARCHAR(25)
)
BEGIN
	DELETE FROM Cart_Items
    WHERE cart_id = cart_idIn AND ISBN = ISBNIn;
END//

CREATE PROCEDURE `cart_empty` (IN cart_idIn INT)
BEGIN
    DELETE FROM Cart_Items
    WHERE cart_id = cart_idIn;
END//

CREATE PROCEDURE `cart_remove` (IN cart_idIn INT)
BEGIN
    DELETE FROM Carts
    WHERE cart_id = cart_idIn;
END//

CREATE PROCEDURE `top_cart_checkout`
(IN cart_idIn INT,
IN user_idIn INT)
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
    proc_exit:BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Custom error';
    END;
    START TRANSACTION;
	CALL cart_checkout(cart_idIn, user_idIn);
	COMMIT;
END//

CREATE PROCEDURE `cart_checkout` (
	IN cart_idIn INT,
	IN user_idIn INT
)
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE ISBNIt VARCHAR(25);
    DECLARE quantityIt INT UNSIGNED;
    DECLARE priceIt DECIMAL UNSIGNED;
    
    DECLARE cart_cursor CURSOR
    FOR	SELECT ISBN, quantity, price
		FROM Cart_Items
        WHERE cart_id = cart_idIn;


    DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET finished = 1;
    
    OPEN cart_cursor;
    
    get_item : LOOP
		FETCH cart_cursor INTO ISBNIT, quantityIt, priceIt;
        IF finished = 1 THEN
			LEAVE get_item;
		END IF;


	-- update quantity of books
        UPDATE Books
        SET quantity = quantity - quantityIt
        WHERE ISBN = ISBNIt;
        
	-- update sales
        INSERT INTO Sales (user_id, ISBN, Timestamp, quantity, price)
        VALUES (user_idIn, ISBNIt, NOW(), quantityIt, priceIt);

	END LOOP get_item;
    
    CLOSE cart_cursor;
    
    CALL cart_empty(cart_idIn);
END//


# Choices Management
CREATE PROCEDURE `get_publishers` ()
BEGIN
    SELECT publisher_id, name
    FROM Publisher;
END //

CREATE PROCEDURE `get_categories` ()
BEGIN
    SELECT category_id, category_name
    FROM Category;
END //

# search Utilities
CREATE PROCEDURE `get_book`(
    IN ISBNIn VARCHAR(25)
)
BEGIN
    SELECT *
    FROM Books
    WHERE ISBN = ISBNIn;
END //

CREATE PROCEDURE `get_books_by_title`(
    IN titleIn VARCHAR(60)
)
BEGIN
    SELECT *
    FROM Books
    WHERE title like titleIn;
END //

CREATE PROCEDURE `get_books_by_author`(
    IN nameIn VARCHAR(50)
)
BEGIN
    SELECT Books.*
    FROM Books JOIN Book_Authors BA on Books.ISBN = BA.ISBN
    WHERE author_name like nameIn;
END //

CREATE PROCEDURE `get_books_by_publisher`(
    IN nameIn VARCHAR(50)
)
BEGIN
    SELECT Books.*
    FROM Books JOIN Publisher P on Books.publisher_id = P.publisher_id
    WHERE name like nameIn;
END //

CREATE PROCEDURE `get_books_by_category`(
    IN categoryIN INT
)
BEGIN
    SELECT *
    FROM Books
    WHERE category_id = categoryIN;
END //

CREATE PROCEDURE `get_manager_orders`()
BEGIN
    SELECT *
    FROM Mng_Order;
END //

CREATE PROCEDURE `get_users_by_username`(
    IN usernameIn VARCHAR(45)
)
BEGIN
    SELECT user_id, username, first_name, last_name
    FROM Users
    WHERE username LIKE usernameIn AND user_id NOT IN (SELECT id FROM Managers);
END //

# Sales
CREATE PROCEDURE `get_top_ten_books`()
BEGIN
    SELECT Sales.ISBN, B.title, SUM(Sales.price * Sales.quantity) as Total
    FROM Sales JOIN Books B on Sales.ISBN = B.ISBN
	WHERE Sales.Timestamp >= LAST_DAY(NOW()) + INTERVAL 1 DAY - INTERVAL 3 MONTH
    AND Sales.Timestamp < LAST_DAY(NOW()) + INTERVAL 1 DAY - INTERVAL 1 MONTH
    GROUP BY Sales.ISBN ORDER BY Total DESC LIMIT 10;
END //

CREATE PROCEDURE `get_top_five_users`()
BEGIN
    SELECT username, first_name, last_name, SUM(Sales.price * Sales.quantity) as Total
    FROM Sales JOIN Users U on Sales.user_id = U.user_id
    WHERE Sales.Timestamp >= LAST_DAY(NOW()) + INTERVAL 1 DAY - INTERVAL 3 MONTH
    AND Sales.Timestamp < LAST_DAY(NOW()) + INTERVAL 1 DAY - INTERVAL 1 MONTH
    GROUP BY Sales.user_id ORDER BY Total DESC LIMIT 5;
END //

CREATE PROCEDURE `get_sales_month`()
BEGIN
    SELECT Sales.ISBN, B.title, SUM(Sales.price * Sales.quantity) as Total
    FROM Sales JOIN Books B on Sales.ISBN = B.ISBN
    WHERE MONTH(Sales.Timestamp) = MONTH(DATE_SUB(CURRENT_DATE ,INTERVAL 1 MONTH))
    GROUP BY Sales.ISBN ORDER BY Total DESC;
END //

# Visa Utilities
CREATE PROCEDURE `check_user_credit`(
    IN user_idIn INT
)
BEGIN
    SELECT *
    FROM Visa
    WHERE user_id = user_idIn;
END //

CREATE PROCEDURE `add_user_credit`(
    IN user_idIn INT,
    IN credit_numberIn VARCHAR(19),
    IN expiryIn DATE
)
BEGIN
    INSERT INTO Visa VALUES (user_idIn, credit_numberIn, expiryIn);
END //

CREATE PROCEDURE `update_user_credit`(
    IN user_idIn INT,
    IN credit_numberIn VARCHAR(19),
    IN expiryIn DATE
)
BEGIN
    UPDATE Visa SET credit_number = credit_numberIn, expiry = expiryIn WHERE user_id = user_idIn;
END //

DELIMITER ;
