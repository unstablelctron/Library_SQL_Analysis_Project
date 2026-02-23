📚 Library Management System using SQL (Project – P2)

images/![Uploading library.jpg…]()

📌 Project Overview

Project Title: Library Management System
Database: library_db

This project demonstrates the design and implementation of a Library Management System using SQL. It covers database creation, table relationships, CRUD operations, CTAS (Create Table As Select), advanced SQL queries, and stored procedures.
The project is designed to showcase real-world database management and analytical querying skills.

🎯 Objectives

Design and implement a relational database for a library system

Perform complete CRUD operations

Use CTAS (Create Table As Select) for summary and analytical tables

Write advanced SQL queries for business insights

Implement stored procedures for book issuing and returning logic

Generate performance and analytical reports

🗂 Project Structure
```
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```
2️⃣ CRUD Operations
Task 1: Create a New Book Record
```
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'); 
````
Task 2: Update an Existing Member’s Address
```
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```
Task 3: Delete an Issued Record
```
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```
Task 4: Retrieve All Books Issued by a Specific Employee
```
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```
Task 5: List Members Who Have Issued More Than One Book
```
SELECT issued_emp_id, COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
````
3️⃣ CTAS (Create Table As Select)
Task 6: Create a Book Issue Summary Table
```
CREATE TABLE book_issued_cnt AS
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```
4️⃣ Data Analysis & Queries
Task 7: Retrieve All Books in a Specific Category
```
SELECT *
FROM books
WHERE category = 'Classic';
```
Task 8: Find Total Rental Income by Category
```
SELECT 
    b.category,
    SUM(b.rental_price) AS total_rental_income,
    COUNT(*) AS total_issues
FROM issued_status AS ist
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;
```
Task 9: List Members Registered in the Last 180 Days
```
SELECT *
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 days;
```
Task 10: List Employees with Branch and Manager Details
```
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.branch_id,
    b.branch_address,
    e2.emp_name AS manager_name
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees AS e2
ON e2.emp_id = b.manager_id;
```
Task 11: Create a Table of Expensive Books
```
CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 7.00;
```
Task 12: Retrieve Books Not Yet Returned
```
SELECT *
FROM issued_status AS ist
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```
5️⃣ Advanced SQL Operations
Task 13: Identify Members with Overdue Books (30+ Days)
```
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
```
6️⃣ Stored Procedures
Task 14: Update Book Status on Return

-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
-- Manually not preffered
``` UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    '978-0-553-29698-2',
    '978-0-14-143951-8',
    '978-0-375-50167-0'
);
```
-- SET PRCCEDURE
```
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
```

Task 15: Branch Performance Report (CTAS)
```
CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    COUNT(ist.issued_id) AS books_issued,
    COUNT(rs.return_id) AS books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id;
```
Task 16: Create a Table of Active Members
```
CREATE TABLE active_members AS 
SELECT * 
FROM members 
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status 
    WHERE issued_date >= CURDATE() - INTERVAL 2 MONTH
);
SELECT * FROM active_members; 
```
Task 17: Employees with the Most Book Issues Processed
```
SELECT 
    e.emp_name,
    b.branch_id,
    COUNT(ist.issued_id) AS books_processed
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id
ORDER BY books_processed DESC
LIMIT 3;
```
Task 18: Stored Procedure to Issue a Book
```
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
```

📊 Reports & Insights

Branch-wise performance analysis

High-demand books identification

Employee productivity tracking

Overdue books and member activity analysis

✅ Conclusion

This project demonstrates end-to-end SQL proficiency, covering:

Database design

Data integrity through constraints

Advanced joins and aggregations

CTAS usage

Stored procedures for real-world business logic

It serves as a strong portfolio project for roles such as Data Analyst, SQL Developer, or Business Analyst.
