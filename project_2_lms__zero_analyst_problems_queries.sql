--Library Management System Project 2 by Hamid

--creating table branch
drop table if exists branch;
create table branch 
	(
		branch_id varchar(5) primary key,
		manager_id varchar(5),
		branch_address varchar(15),
		contact_no varchar(15)
	);

--creating table employees
drop table if exists employees;
create table employees 
	(
		emp_id varchar(6) primary key,
		emp_name varchar(20),
		position varchar(9),
		salary varchar(7),
		branch_id varchar(7)
	);

alter table employees
alter column salary type varchar(20);

--creating table books
drop table if exists books;
create table books 
	(
		isbn varchar(20) primary key,
		book_title varchar(25),
		category varchar(20),
		rental_price float,
		status varchar(5),
		author varchar(20),
		publisher varchar(25)
	);
--there was issue importing data into books table because of the book_title
--column being too short so altered the table's column to increase its size
alter table books
alter column book_title type varchar(75);

alter table books
alter column author type varchar(50);


--creating table issued_status
drop table if exists issued_status;
create table issued_status
	(
		issued_id varchar(10) primary key,
		issued_member_id varchar(10), --fk
		issued_book_name varchar(20),
		issued_date date,
		issued_book_isbn varchar(20), --fk
		issued_emp_id varchar(6) --fk
	);

alter table issued_status
alter column issued_book_name type varchar(75);

--creating table members
drop table if exists members;
create table members
	(
		member_id varchar(7) primary key,
		member_name varchar(20),
		member_address varchar(25),
		reg_date date
	);

--creating table return_status
drop table if exists return_status;
create table return_status
	(
		return_id varchar(8) primary key,
		issued_id varchar(8),
		return_book_name varchar(25),
		return_date date,
		return_book_isbn varchar(8)
	);

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');

SELECT * FROM return_status;

--Foreign key constraints
alter table issued_status
add constraint fk_members_id
foreign key (issued_member_id)
references members(member_id);

alter table issued_status  --table where we add col from another table as fk
add constraint fk_book_isbn --cmd for adding constraint and its name
foreign key (issued_book_isbn) --the col as a fk (name from the 2nd table)
references books(isbn); --1st table and the name of col over there

alter table issued_status
add constraint fk_emp_id
foreign key(issued_emp_id)
references employees(emp_id);

alter table return_status
add constraint fk_issued_id
foreign key(issued_id)
references issued_status(issued_id);

alter table employees
add constraint fk_branch_id
foreign key(branch_id)
references branch(branch_id);


--verifying all the data if imported correctly
select * from books;  --35 rows 
select * from branch; --5 rows
select * from employees; --11 rows
select * from issued_status; --35 rows
select * from members; --12 rows
select * from return_status; --14 rows


--PROBLEMS AND ANALYTICS

--CRUD OPERATIONS

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a 
--Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
select * from books;  --always see the data before solving the problem
insert into books (isbn, book_title, category, rental_price, status, author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address
select * from members; 
update members
set member_address = '124 Main St'
where member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table -- Objective: 
--Delete the record with issued_id = 'IS121' from the issued_status table.
select * from issued_status; --35 rows
delete from issued_status where issued_id = 'IS121'; --34 rows

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: 
--Select all books issued by the employee with emp_id = 'E101'.
select issued_book_name from issued_status where issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: 
--Use GROUP BY to find members who have issued more than one book.
select issued_member_id, count(issued_id) as no_of_books_issued 
from issued_status group by issued_member_id having count(issued_id)>1;

select issued_member_id, count(*) from issued_status
group by 1 having count(*)>1;


--CTAS (Create Table As Select)
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on 
--query results - each book and total book_issued_cnt**
create table book_issued_time 
as
select 
	b.isbn, 
	b.book_title, 
	count(ist.issued_id) as issued_times 
from books b
join
issued_status ist on ist.issued_book_isbn = b.isbn
group by 1,2;

select * from book_issued_time; 

--Data Analysis & Findings
--Task 7. Retrieve All Books in a Specific Category:
select * from books;
select * from books where category = 'Literary Fiction';

--Task 8: Find Total Rental Income by Category:
select 
	category, 
	sum(rental_price) as total_rental_income
from books 
group by 1;

--Task 9: List Members Who Registered in the Last 180 Days:
insert into members(member_id, member_name, member_address, reg_date)
values
('C1199','SAM','145 main street','2025-06-01'),
('C1190','John','146 main street','2025-05-01');

select * from members
where reg_date >= current_date - interval '180 days'

--Task 10: List Employees with Their Branch Manager's Name and 
--their branch details:
select * from branch;

select e1.*, b.branch_id, e2.emp_name as manager	
	from employees e1
join
branch b on e1.branch_id = b.branch_id
join 
employees e2
on b.manager_id = e2.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain 
--Threshold:
create table expensive_books as
select * from books
where rental_price > 8.00;

--Task 12: Retrieve the List of Books Not Yet Returned
select distinct ist.issued_book_name from issued_status ist
left join 
return_status rs
on ist.issued_id = rs.issued_id
where return_date is null;


--ADVANCE POSTGRESQL PROBLEMS
select * from return_status;

/*Task 13:  Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's 
name, book title, issue date, and days overdue.*/
select ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date, 
current_date - ist.issued_date as over_due_days
from issued_status as ist
join members as m on ist.issued_member_id = m.member_id
join books as bk on ist.issued_book_isbn = bk.isbn
left join return_status r on ist.issued_id = r.issued_id 
where r.return_date is null
and (current_date - ist.issued_date)>30
order by 1;

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the 
return_status table).*/
create or replace procedure add_return_record(p_return_id varchar(10), p_issued_id varchar(10), p_book_quality varchar(10))
language plpgsql
as $$
declare
	v_isbn varchar(50);
	v_book_name varchar(80);
begin
	insert into return_status(return_id, issued_id, return_date, book_quality)
	values(p_return_id, p_issued_id, current_date, p_book_quality);

	select 
		issued_book_isbn,
		issued_book_name
		into 
			v_isbn, v_book_name
		from issued_status
		where
			issued_id = p_issued_id;
	
	update books
	set status = 'Yes'
	where isbn = v_isbn;

	raise notice 'Thank you for returning the book: %', v_book_name;
end;
$$

call add_return_record();

--Testing call add_return_record();

select * from books;
select * from issued_status
where issued_book_isbn = '978-0-307-58837-1';
select * from return_status
where issued_id = 'IS135';

call add_return_record('RS138', 'IS135', 'Good');

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

create table branchs_report
as
select 
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as no_of_books_issued,
	count(rs.return_id) as no_of_books_returned,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join
employees as e 
on e.emp_id = ist.issued_emp_id
join
branch as b
on b.branch_id = e.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join
books as bk
on bk.isbn = ist.issued_book_isbn
group by 1, 2;

select * from branchs_report;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have 
issued at least one book in the last 2 months.*/
select 
	issued_member_id
	from issued_status
where
	issued_date > current_date - interval '6 months';

--to get the member's names as well; i had to join the members table's as well
create table active_members as
select m.member_id, m.member_name, ist.issued_date  from members as m
join 
issued_status as ist
on m.member_id = ist.issued_member_id
where
	issued_date > current_date - interval '6 months';

--we can use subquery as well to get the names
create table active_members_subquery as
select * from members
where 
	member_id in
		(select
			issued_member_id
			from issued_status
		where
			issued_date > current_date - interval '6 months');
--ctas
select * from active_members;
select * from active_members_subquery;


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, 
number of books processed, and their branch.*/
select e.emp_name, b.*, count(ist.issued_id) as no_of_books_issued  from issued_status as ist
join employees as e on e.emp_id = ist.issued_emp_id
join branch as b on b.branch_id = e.branch_id
group by 1,2 order by no_of_books_issued desc limit 3

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" 
in the books table. Display the member name, book title, and the number of times they've issued damaged books.*/
--first make some books as 'damaged'
update return_status
set book_quality = 'Damaged'
where issued_id in ('IS107', 'IS108', 'IS109', '1S113', '1S114', '1S115');

select m.member_name, count(*) as damaged_books from members as m
join issued_status as ist on m.member_id = ist.issued_member_id
join books as bk on bk.isbn = ist.issued_book_isbn
join return_status as rs on rs.issued_id = ist.issued_id
where rs.book_quality = 'Damaged'
group by 1
having count(*) > 2;

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should 
return an error message indicating that the book is currently not available.*/
select * from books;
select * from issued_status;	

create or replace procedure issue_book(p_issued_id varchar(10), p_issued_member_id varchar(10), p_issued_book_isbn varchar(20),
p_issued_emp_id varchar(6))

Language plpgsql
As $$

Declare 
	v_status varchar(5);
Begin
		select status
		into
			v_status
		from books where isbn = p_issued_book_isbn;
		
		if lower(v_status) = 'yes' then
			insert into issued_status(issued_id, issued_member_id, issued_book_isbn, issued_emp_id)
			values(p_issued_id, p_issued_member_id, p_issued_book_isbn, p_issued_emp_id);

		update books
		set status = 'No'
		where isbn = p_issued_book_isbn;

		raise notice 'Book record added successfuly for the book isbn: %', p_issued_book_isbn;
		
		else
				raise notice 'Sorry the book you requested is unavailable isbn: %', p_issued_book_isbn;

		end if;
End;
$$

select * from issued_status;
select * from books
where isbn = '978-0-553-29698-2'; --now the status would have changed to 'no' after issuing the mentioned isbn book

--978-0-553-29698-2     'Yes'
--978-0-7432-7357-1     'No'

call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E102');
