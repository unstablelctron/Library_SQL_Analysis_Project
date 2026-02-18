SELECT * FROM issued_status;
SELECT * FROM employees;
SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM return_status;

-- Project Database
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books 
(isbn, book_title, category, rental_price, status, author, publisher)
VALUES 
('978-1-60129-456-2', 
 'To Kill a Mockingbird', 
 'Classic', 
 6.00, 
 'yes', 
 'Harper Lee', 
 'J.B. Lippincott & Co.');
 select * from books;
  select * from members;
 -- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = 'Viraj Khand'
WHERE member_id = 'C102';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';

 -- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
 
 SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
       COUNT(*) AS total_issues
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_issued_cnt as 
select b.isbn , b.book_title , count(ist.issued_id) as total_issue
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
group by b.isbn , b.book_title;

select * from book_issued_cnt;

-- Task 7. Retrieve All Books in a Specific Category:

select * 
from books
where category = 'classic';

-- Task 8: Find Total Rental Income by Category:
 select b.category , sum(b.rental_price) as total_rental_income , count(*)
 from issued_status as ist
 join books as b
 on ist.issued_book_isbn = b.isbn
 group by category;
 
-- Task 9 List Members Who Registered in the Last 180 Days:

select * from members
where reg_date >= current_date - interval 180 day ;

-- Task 10 : List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e.emp_name,
    e.emp_id,
    e.salary,
    e.position,
    b.*,
    e1.emp_name AS manager
FROM employees AS e
JOIN branch AS b
    ON e.branch_id = b.branch_id
JOIN employees AS e1
    ON e1.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

select * from issued_status as ist
left join
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

select 	m.member_id , m.member_name , 
b.book_title ,
i.issued_date,
datediff(curdate() , i.issued_date) - 30 days_overdue
from issued_status i
join members m on
i.issued_member_id = m.member_id
join books b
on i.issued_book_isbn = b.isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = i.issued_id
WHERE 
rs.return_date IS NULL and 
datediff(curdate() , i.issued_date) >30
order by 1;

-- Adding Records

select * from issued_status;
-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
-- SELECT * from issued_status



INSERT INTO issued_status
(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 DAY, '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 DAY, '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 DAY,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road',              CURRENT_DATE - INTERVAL 32 DAY, '978-0-375-50167-0', 'E101');


-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

SET SQL_SAFE_UPDATES = 0;
UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
-- Manually not preffered
UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    '978-0-553-29698-2',
    '978-0-14-143951-8',
    '978-0-375-50167-0'
);
-- SET PRCCEDURE
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Get book details from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book availability
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Confirmation message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END$$

-- Testing FUNCTION add_return_records

-- Step 1: Book status check (Before Return)
SELECT * 
FROM books
WHERE isbn = '978-0-307-58837-1';

-- Step 2: Issued record verification
SELECT *
FROM issued_status
WHERE issued_id = 'IS135';

-- Step 3: Return table check (Before procedure call)
SELECT *
FROM return_status
WHERE issued_id = 'IS135';

-- Step 4: Call Stored Procedure
CALL add_return_records('RS138', 'IS135', 'Good');

-- Step 5: Verify Book Status (After Return)
SELECT * 
FROM books
WHERE isbn = '978-0-307-58837-1';

-- Step 6: Verify Return Entry
SELECT *
FROM return_status
WHERE issued_id = 'IS135';

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(i.issued_id) AS total_issued,
    COUNT(r.return_id) AS total_returned,
    SUM(bo.rental_price) AS total_revenue
FROM issued_status AS i
JOIN employees AS e
    ON e.emp_id = i.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
LEFT JOIN return_status AS r
    ON r.issued_id = i.issued_id
JOIN books AS bo
    ON bo.isbn = i.issued_book_isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members AS 
SELECT * 
FROM members 
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status 
    WHERE issued_date >= CURDATE() - INTERVAL 2 MONTH
);
SELECT * FROM active_members; 

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_name,
    b.branch_id,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name,
    b.branch_id
ORDER BY 
    no_book_issued DESC
LIMIT 3;

-- Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Check book availability
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURDATE(),
            p_issued_book_isbn,
            p_issued_emp_id
        );

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT(
            'Book issued successfully. ISBN: ',
            p_issued_book_isbn
        ) AS message;

    ELSE
        SELECT CONCAT(
            'Sorry, the requested book is unavailable. ISBN: ',
            p_issued_book_isbn
        ) AS message;
    END IF;

END$$


































