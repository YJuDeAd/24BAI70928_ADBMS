--Q1:
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30)
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary NUMERIC(10,2),
    dept_id INT REFERENCES department(dept_id)
);

INSERT INTO department VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee VALUES
(101, 'Aman', 90000, 1),
(102, 'Neha', 70000, 1),
(103, 'Raj', 50000, 1),
(104, 'Priya', 80000, 2),
(105, 'Karan', 60000, 2),
(106, 'Riya', 40000, 2),
(107, 'Mohit', 75000, 3),
(108, 'Simran', 55000, 3);


SELECT 
	d.dept_name AS Department, 
	e.emp_name AS Salary,
	e.salary
FROM employee e
JOIN department d
ON e.dept_id = d.dept_id
WHERE e.salary > (
	SELECT AVG(e2.salary)
	FROM employee e2
	WHERE e.dept_id = e2.dept_id
) AND e.dept_id in (
	SELECT dept_id
	FROM employee 
	GROUP BY dept_id 
	HAVING COUNT(*) >= 3
)




--Q2:
DROP TABLE IF EXISTS bank_customer CASCADE;
DROP TABLE IF EXISTS customer_audit CASCADE;

CREATE TABLE bank_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    balance NUMERIC(10,2)
);

CREATE TABLE customer_audit (
    audit_id SERIAL PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(50),
    action VARCHAR(20),
    action_time TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit()
    RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN                                                                                      
            INSERT INTO customer_audit(customer_id, customer_name, action, action_time)                                 
            VALUES (NEW.customer_id, NEW.customer_name, 'ADDED', CURRENT_TIMESTAMP);                                    
            RETURN NEW;                                                                                                 
        ELSIF (TG_OP = 'DELETE') THEN                                                                                   
            INSERT INTO customer_audit (customer_id, customer_name, action, action_time)
            VALUES (OLD.customer_id, OLD.customer_name, 'REMOVED', CURRENT_TIMESTAMP);
            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER bank_customer_audit_trigger
AFTER INSERT OR DELETE ON bank_customer
FOR EACH ROW
EXECUTE FUNCTION audit();

INSERT INTO bank_customer VALUES
(1, 'Rahul', 50000),
(2, 'Neha', 75000);

DELETE FROM bank_customer 
WHERE customer_id = 1;

SELECT * 
FROM customer_audit;

