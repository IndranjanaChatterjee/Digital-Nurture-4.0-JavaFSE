-- Schema to be Created

CREATE TABLE CUSTOMERS (
    CUSTOMERID   NUMBER PRIMARY KEY,
    NAME         VARCHAR2(100),
    DOB          DATE,
    BALANCE      NUMBER,
    LASTMODIFIED DATE
);

CREATE TABLE ACCOUNTS (
    ACCOUNTID    NUMBER PRIMARY KEY,
    CUSTOMERID   NUMBER,
    ACCOUNTTYPE  VARCHAR2(20),
    BALANCE      NUMBER,
    LASTMODIFIED DATE,
    FOREIGN KEY ( CUSTOMERID )
        REFERENCES CUSTOMERS ( CUSTOMERID )
);

CREATE TABLE TRANSACTIONS (
    TRANSACTIONID   NUMBER PRIMARY KEY,
    ACCOUNTID       NUMBER,
    TRANSACTIONDATE DATE,
    AMOUNT          NUMBER,
    TRANSACTIONTYPE VARCHAR2(10),
    FOREIGN KEY ( ACCOUNTID )
        REFERENCES ACCOUNTS ( ACCOUNTID )
);

CREATE TABLE LOANS (
    LOANID       NUMBER PRIMARY KEY,
    CUSTOMERID   NUMBER,
    LOANAMOUNT   NUMBER,
    INTERESTRATE NUMBER,
    STARTDATE    DATE,
    ENDDATE      DATE,
    FOREIGN KEY ( CUSTOMERID )
        REFERENCES CUSTOMERS ( CUSTOMERID )
);

CREATE TABLE EMPLOYEES (
    EMPLOYEEID NUMBER PRIMARY KEY,
    NAME       VARCHAR2(100),
    POSITION   VARCHAR2(50),
    SALARY     NUMBER,
    DEPARTMENT VARCHAR2(50),
    HIREDATE   DATE
);

-- Example Scripts for Sample Data Insertion

-- INSERT INTO CUSTOMERS
INSERT INTO CUSTOMERS (CUSTOMERID, NAME, DOB, BALANCE, LASTMODIFIED)
VALUES (1, 'John Doe', TO_DATE('1985-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);
INSERT INTO CUSTOMERS (CUSTOMERID, NAME, DOB, BALANCE, LASTMODIFIED)
VALUES (2, 'Jane Smith', TO_DATE('1990-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

-- INSERT INTO ACCOUNTS
INSERT INTO ACCOUNTS (ACCOUNTID, CUSTOMERID, ACCOUNTTYPE, BALANCE, LASTMODIFIED)
VALUES (1, 1, 'Savings', 1000, SYSDATE);
INSERT INTO ACCOUNTS (ACCOUNTID, CUSTOMERID, ACCOUNTTYPE, BALANCE, LASTMODIFIED)
VALUES (2, 2, 'Checking', 1500, SYSDATE);

-- INSTER INTO TRANSACTIONS
INSERT INTO TRANSACTIONS (TRANSACTIONID, ACCOUNTID, TRANSACTIONDATE, AMOUNT, TRANSACTIONTYPE)
VALUES (1, 1, SYSDATE, 200, 'Deposit');
INSERT INTO TRANSACTIONS (TRANSACTIONID, ACCOUNTID, TRANSACTIONDATE, AMOUNT, TRANSACTIONTYPE)
VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

-- INSERT INTO LOANS
INSERT INTO LOANS (LOANID, CUSTOMERID, LOANAMOUNT, INTERESTRATE, STARTDATE, ENDDATE)
VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));

-- INSERT INTO EMPLOYEES
INSERT INTO EMPLOYEES (EMPLOYEEID, NAME, POSITION, SALARY, DEPARTMENT, HIREDATE)
VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('2015-06-15', 'YYYY-MM-DD'));
INSERT INTO EMPLOYEES (EMPLOYEEID, NAME, POSITION, SALARY, DEPARTMENT, HIREDATE)
VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));



-- QUESTIONS AND SOLUTIONS

/*

Exercise 1: Control Structures

Scenario 1: The bank wants to apply a discount to loan interest rates for customers above 60 years old.
        ? Question: Write a PL/SQL block that loops through all customers, checks their age, 
           and if they are above 60, apply a 1% discount to their current loan interest rates.
Scenario 2: A customer can be promoted to VIP status based on their balance.
        ? Question: Write a PL/SQL block that iterates through all customers and sets a flag IsVIP to TRUE 
           for those with a balance over $10,000.
Scenario 3: The bank wants to send reminders to customers whose loans are due within the next 30 days.
        ? Question: Write a PL/SQL block that fetches all loans due in the next 30 days and prints a reminder 
            message for each customer.

*/

-- SCENARIO 1

SELECT * FROM CUSTOMERS;
SELECT * FROM LOANS;

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUSTOMER_CURSOR IS
        SELECT CUSTOMERID, EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DOB) AS AGE
        FROM CUSTOMERS;
    VAR_CUSTOMER_ID CUSTOMERS.CUSTOMERID%TYPE;
    VAR_AGE NUMBER;
BEGIN
    FOR CUSTOMER_RECORD IN CUSTOMER_CURSOR LOOP
        VAR_CUSTOMER_ID := CUSTOMER_RECORD.CUSTOMERID;
        VAR_AGE := CUSTOMER_RECORD.AGE;
        IF VAR_AGE > 60 THEN
            UPDATE LOANS
            SET INTERESTRATE = INTERESTRATE - 1
            WHERE CUSTOMERID = VAR_CUSTOMER_ID;
        ELSE
            DBMS_OUTPUT.PUT_LINE('CUSTOMER WITH CUSTOMER ID : ' || VAR_CUSTOMER_ID || ' IS OF AGE : ' || VAR_AGE);
            DBMS_OUTPUT.PUT_LINE('NO CHANGE IN LOAN');
        END IF;
    END LOOP;
    COMMIT;
END;
/

SELECT * FROM LOANS;

-- SCENARIO 2

DESC CUSTOMERS;
ALTER TABLE CUSTOMERS ADD ISVIP CHAR(10) CONSTRAINT CHK1 CHECK(ISVIP IN ('TRUE','FALSE')) ;

SELECT * FROM CUSTOMERS;
SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUSTOMER_CURSOR IS
        SELECT CUSTOMERID, BALANCE
        FROM CUSTOMERS;
    VAR_CUSTOMER_ID CUSTOMERS.CUSTOMERID%TYPE;
    VAR_BALANCE CUSTOMERS.BALANCE%TYPE;
BEGIN
    FOR CUSTOMER_RECORD IN CUSTOMER_CURSOR LOOP
        VAR_CUSTOMER_ID := CUSTOMER_RECORD.CUSTOMERID;
        VAR_BALANCE := CUSTOMER_RECORD.BALANCE;
        IF VAR_BALANCE > 10000 THEN
            DBMS_OUTPUT.PUT_LINE('CUSTOMER ID : ' || VAR_CUSTOMER_ID || ' HAS BALANCE GREATER THAN 10000');
            UPDATE CUSTOMERS
            SET ISVIP = 'TRUE'
            WHERE CUSTOMERID = VAR_CUSTOMER_ID;
        ELSE
            DBMS_OUTPUT.PUT_LINE('CUSTOMER ID : ' || VAR_CUSTOMER_ID || ' HAS BALANCE LESSER THAN 10000');
            UPDATE CUSTOMERS
            SET ISVIP = 'FALSE'
            WHERE CUSTOMERID = VAR_CUSTOMER_ID;
        END IF;
    END LOOP;
    COMMIT;
END;
/
SELECT * FROM CUSTOMERS;

-- SCENARIO 3

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUR_LOANS IS
        SELECT L.LOANID, L.CUSTOMERID, C.NAME, L.ENDDATE
        FROM LOANS L
        JOIN CUSTOMERS C ON L.CUSTOMERID = C.CUSTOMERID
        WHERE L.ENDDATE BETWEEN SYSDATE AND SYSDATE + 30;
    
    V_LOAN_ID LOANS.LOANID%TYPE;
    V_CUSTOMER_ID LOANS.CUSTOMERID%TYPE;
    V_CUSTOMER_NAME CUSTOMERS.NAME%TYPE;
    V_END_DATE LOANS.ENDDATE%TYPE;
    V_FOUND BOOLEAN := FALSE;
BEGIN
    OPEN CUR_LOANS;
    LOOP
        FETCH CUR_LOANS INTO V_LOAN_ID, V_CUSTOMER_ID, V_CUSTOMER_NAME, V_END_DATE;
        EXIT WHEN CUR_LOANS%NOTFOUND;
        
        V_FOUND := TRUE;
        DBMS_OUTPUT.PUT_LINE('Reminder: Loan ' || V_LOAN_ID || ' for customer ' || V_CUSTOMER_NAME || ' (ID: ' || V_CUSTOMER_ID || ') is due on ' || TO_CHAR(V_END_DATE, 'YYYY-MM-DD'));
    END LOOP;
    CLOSE CUR_LOANS;

    IF NOT V_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No loans are due within the next 30 days.');
    END IF;
END;
/

/*

Exercise 2: Error Handling

Scenario 1: Handle exceptions during fund transfers between accounts.
        ? Question: Write a stored procedure SafeTransferFunds that transfers funds between two accounts. 
            Ensure that if any error occurs (e.g., insufficient funds), an appropriate error message is logged 
            and the transaction is rolled back.
Scenario 2: Manage errors when updating employee salaries.
        ? Question: Write a stored procedure UpdateSalary that increases the salary of an employee by a given percentage. 
            If the employee ID does not exist, handle the exception and log an error message.
Scenario 3: Ensure data integrity when adding a new customer.
        ? Question: Write a stored procedure AddNewCustomer that inserts a new customer into the Customers table. 
            If a customer with the same ID already exists, handle the exception by logging an error and preventing 
            the insertion.

*/

-- SCENARIO 1

SELECT * FROM ACCOUNTS;

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SAFETRANSFERFUNDS(
    P_FROM_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
    P_TO_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
    P_AMOUNT IN NUMBER
) AS
    V_FROM_BALANCE ACCOUNTS.BALANCE%TYPE;
    V_TO_BALANCE ACCOUNTS.BALANCE%TYPE;
BEGIN
    
    SELECT BALANCE INTO V_FROM_BALANCE
    FROM ACCOUNTS
    WHERE ACCOUNTID = P_FROM_ACCOUNT_ID
    FOR UPDATE;
    
    SELECT BALANCE INTO V_TO_BALANCE
    FROM ACCOUNTS
    WHERE ACCOUNTID = P_TO_ACCOUNT_ID
    FOR UPDATE;
    
    -- Check for sufficient funds
    IF V_FROM_BALANCE < P_AMOUNT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in the source account.');
    END IF;
    
    -- Perform the transfer
    UPDATE ACCOUNTS
    SET BALANCE = BALANCE - P_AMOUNT,
        LASTMODIFIED = SYSDATE
    WHERE ACCOUNTID = P_FROM_ACCOUNT_ID;
    
    UPDATE ACCOUNTS
    SET BALANCE = BALANCE + P_AMOUNT,
        LASTMODIFIED = SYSDATE
    WHERE ACCOUNTID = P_TO_ACCOUNT_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer successful.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed: ' || SQLERRM);
END SAFETRANSFERFUNDS;
/

EXEC SAFETRANSFERFUNDS(2,1,500);
SELECT * FROM ACCOUNTS;

-- SCENARIO 2

SELECT * FROM EMPLOYEES;

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE UPDATESALARY(
    P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE,
    P_PERCENTAGE IN NUMBER
) AS
    V_OLD_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    -- Fetch the current salary
    SELECT SALARY INTO V_OLD_SALARY
    FROM EMPLOYEES
    WHERE EMPLOYEEID = P_EMPLOYEE_ID;

    -- Update the salary
    UPDATE EMPLOYEES
    SET SALARY = SALARY * (1 + P_PERCENTAGE / 100),
        HIREDATE = SYSDATE
    WHERE EMPLOYEEID = P_EMPLOYEE_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salary updated successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || P_EMPLOYEE_ID || ' does not exist.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Salary update failed: ' || SQLERRM);
END UPDATESALARY;
/

EXEC UPDATESALARY(1,5);
EXEC UPDATESALARY(2,3);

SELECT * FROM EMPLOYEES;

-- SCENARIO 3

SELECT * FROM CUSTOMERS;

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE ADDNEWCUSTOMER(
    P_CUSTOMER_ID IN CUSTOMERS.CUSTOMERID%TYPE,
    P_NAME IN CUSTOMERS.NAME%TYPE,
    P_DOB IN CUSTOMERS.DOB%TYPE,
    P_BALANCE IN CUSTOMERS.BALANCE%TYPE
) AS
BEGIN
    -- Attempt to insert the new customer
    DBMS_OUTPUT.PUT_LINE('INSERTING...');
    DBMS_OUTPUT.PUT_LINE('CUSTOMER_ID : ' || P_CUSTOMER_ID);
    DBMS_OUTPUT.PUT_LINE('NAME : ' || P_NAME);
    DBMS_OUTPUT.PUT_LINE('DOB : ' || P_DOB);
    DBMS_OUTPUT.PUT_LINE('BALANCE : ' || P_BALANCE);
    
    INSERT INTO CUSTOMERS (CUSTOMERID, NAME, DOB, BALANCE, LASTMODIFIED)
    VALUES (P_CUSTOMER_ID, P_NAME, TO_DATE(P_DOB,'YYYY-MM-DD'), P_BALANCE, SYSDATE);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Customer added successfully.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Customer ID ' || P_CUSTOMER_ID || ' already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Customer addition failed: ' || SQLERRM);
END ADDNEWCUSTOMER;
/

EXEC ADDNEWCUSTOMER(3,'INDRANJANA CHATTERJEE','18-08-2003',50000);

SELECT * FROM CUSTOMERS;

/*

Exercise 3: Stored Procedures

Scenario 1: The bank needs to process monthly interest for all savings accounts.
        ? Question: Write a stored procedure ProcessMonthlyInterest that calculates and 
            updates the balance of all savings accounts by applying an interest rate of 1% to the current balance.

Scenario 2: The bank wants to implement a bonus scheme for employees based on their performance.
        ? Question: Write a stored procedure UpdateEmployeeBonus that updates the salary of employees 
            in a given department by adding a bonus percentage passed as a parameter.

Scenario 3: Customers should be able to transfer funds between their accounts.
        ? Question: Write a stored procedure TransferFunds that transfers a specified amount from one account to another, 
            checking that the source account has sufficient balance before making the transfer.

*/

-- SCENARIO 1

SELECT * FROM ACCOUNTS;
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE PROCESSMONTHLYINTEREST AS
BEGIN
    UPDATE ACCOUNTS
    SET BALANCE = BALANCE * 1.01,
        LASTMODIFIED = SYSDATE
    WHERE ACCOUNTTYPE = 'Savings';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Monthly interest processed for all savings accounts.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error processing monthly interest: ' || SQLERRM);
END PROCESSMONTHLYINTEREST;
/

EXEC PROCESSMONTHLYINTEREST();

SELECT * FROM ACCOUNTS;

-- SCENARIO 2

SELECT * FROM EMPLOYEES;

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE UPDATEEMPLOYEEBONUS(
    P_DEPARTMENT IN EMPLOYEES.DEPARTMENT%TYPE,
    P_BONUS_PERCENTAGE IN NUMBER
) AS
BEGIN
    UPDATE EMPLOYEES
    SET SALARY = SALARY * (1 + P_BONUS_PERCENTAGE / 100),
        HIREDATE = SYSDATE
    WHERE DEPARTMENT = P_DEPARTMENT;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bonus applied to employees in the ' || P_DEPARTMENT || ' department.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating employee bonuses: ' || SQLERRM);
END UPDATEEMPLOYEEBONUS;
/

EXEC UPDATEEMPLOYEEBONUS('IT',5);
EXEC UPDATEEMPLOYEEBONUS('HR',3);

SELECT * FROM EMPLOYEES;

-- SCENARIO 3

SELECT * FROM ACCOUNTS;
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE TRANSFERFUNDS(
    P_FROM_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
    P_TO_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
    P_AMOUNT IN NUMBER
) AS
    V_FROM_BALANCE ACCOUNTS.BALANCE%TYPE;
BEGIN
    
    SELECT BALANCE INTO V_FROM_BALANCE
    FROM ACCOUNTS
    WHERE ACCOUNTID = P_FROM_ACCOUNT_ID
    FOR UPDATE;
    
    -- Check for sufficient funds
    IF V_FROM_BALANCE < P_AMOUNT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in the source account.');
    END IF;
    
    -- Perform the transfer
    UPDATE ACCOUNTS
    SET BALANCE = BALANCE - P_AMOUNT,
        LASTMODIFIED = SYSDATE
    WHERE ACCOUNTID = P_FROM_ACCOUNT_ID;
    
    UPDATE ACCOUNTS
    SET BALANCE = BALANCE + P_AMOUNT,
        LASTMODIFIED = SYSDATE
    WHERE ACCOUNTID = P_TO_ACCOUNT_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer of ' || P_AMOUNT || ' from account ' || P_FROM_ACCOUNT_ID || ' to account ' || P_TO_ACCOUNT_ID || ' completed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed: ' || SQLERRM);
END TRANSFERFUNDS;
/

EXEC TRANSFERFUNDS(1,2,100);

SELECT * FROM ACCOUNTS;

/*

Exercise 4: Functions

Scenario 1: Calculate the age of customers for eligibility checks.
        ? Question: Write a function CalculateAge that takes a customer's date of birth as input and 
            returns their age in years.

Scenario 2: The bank needs to compute the monthly installment for a loan.
        ? Question: Write a function CalculateMonthlyInstallment that takes the loan amount, interest rate, 
            and loan duration in years as input and returns the monthly installment amount.

Scenario 3: Check if a customer has sufficient balance before making a transaction.
        ? Question: Write a function HasSufficientBalance that takes an account ID and an amount as input and 
            returns a boolean indicating whether the account has at least the specified amount.

*/

-- SCENARIO 1

DELETE FROM CUSTOMERS WHERE CUSTOMERID = 3;
SELECT * FROM CUSTOMERS;

SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION CALCULATEAGE(
    P_DOB IN DATE
) RETURN NUMBER IS
    V_AGE NUMBER;
BEGIN
    V_AGE := TRUNC((SYSDATE - P_DOB) / 365);
    RETURN V_AGE;
END CALCULATEAGE;
/

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CURSOR_CUST IS SELECT CUSTOMERID, DOB FROM CUSTOMERS;
    V_CUSTOMERID CUSTOMERS.CUSTOMERID%TYPE;
    V_DOB CUSTOMERS.DOB%TYPE;
    V_AGE NUMBER;
BEGIN
    OPEN CURSOR_CUST;
    LOOP
        FETCH CURSOR_CUST INTO V_CUSTOMERID, V_DOB;
        EXIT WHEN CURSOR_CUST%NOTFOUND;
        
        V_AGE := CALCULATEAGE(V_DOB);
        
        DBMS_OUTPUT.PUT_LINE('CUSTOMER ID : ' || V_CUSTOMERID || ' AGE : ' || V_AGE);
    END LOOP;
    CLOSE CURSOR_CUST;
END;
/

-- SCENARIO 2

SELECT * FROM LOANS;

SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION CALCULATEMONTHLYINSTALLMENT(
    P_LOAN_AMOUNT IN NUMBER,
    P_INTEREST_RATE IN NUMBER,
    P_LOAN_DURATION_YEARS IN NUMBER
) RETURN NUMBER IS
    V_MONTHLY_RATE NUMBER;
    V_NUM_PAYMENTS NUMBER;
    V_MONTHLY_INSTALLMENT NUMBER;
BEGIN
    V_MONTHLY_RATE := P_INTEREST_RATE / 12 / 100;
    V_NUM_PAYMENTS := P_LOAN_DURATION_YEARS * 12;
    IF V_MONTHLY_RATE = 0 THEN
        V_MONTHLY_INSTALLMENT := P_LOAN_AMOUNT / V_NUM_PAYMENTS;
    ELSE
        V_MONTHLY_INSTALLMENT := P_LOAN_AMOUNT * V_MONTHLY_RATE / (1 - POWER(1 + V_MONTHLY_RATE, -V_NUM_PAYMENTS));
    END IF;
    RETURN V_MONTHLY_INSTALLMENT;
END CALCULATEMONTHLYINSTALLMENT;
/

SET SERVEROUTPUT ON;
DECLARE
    CURSOR LOAN_CUR IS SELECT * FROM LOANS;
    V_DATA LOANS%ROWTYPE;
    V_DURATION NUMBER;
    V_MONTHLYINSTALLMENT NUMBER;
BEGIN
    OPEN LOAN_CUR;
    LOOP
        FETCH LOAN_CUR INTO V_DATA;
        EXIT WHEN LOAN_CUR%NOTFOUND;
           
        V_DURATION := TRUNC((V_DATA.ENDDATE - V_DATA.STARTDATE)/365);
        V_MONTHLYINSTALLMENT :=  TRUNC(CALCULATEMONTHLYINSTALLMENT(V_DATA.LOANAMOUNT, V_DATA.INTERESTRATE, V_DURATION),2);
        DBMS_OUTPUT.PUT_LINE('CUSTOMER ID : ' || V_DATA.CUSTOMERID || ' MONTHLY INSTALLAMENT : ' || V_MONTHLYINSTALLMENT);
        
    END LOOP;
    CLOSE LOAN_CUR;
END;
/
        
-- SCENARIO 3

SELECT * FROM ACCOUNTS;

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION HASSUFFICIENTBALANCE(
    P_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
    P_AMOUNT IN NUMBER
) RETURN BOOLEAN IS
    V_BALANCE ACCOUNTS.BALANCE%TYPE;
BEGIN
    SELECT BALANCE INTO V_BALANCE
    FROM ACCOUNTS
    WHERE ACCOUNTID = P_ACCOUNT_ID;

    RETURN V_BALANCE >= P_AMOUNT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error checking balance: ' || SQLERRM);
END HASSUFFICIENTBALANCE;
/

SET SERVEROUTPUT ON;
DECLARE
    V_ACCOUNTID ACCOUNTS.ACCOUNTID%TYPE := &ACCOUNTID;
    V_AMOUNT NUMBER := &AMOUNT;
    V_HAS BOOLEAN;
BEGIN
    V_HAS  := HASSUFFICIENTBALANCE(V_ACCOUNTID, V_AMOUNT);
    IF V_HAS = TRUE THEN DBMS_OUTPUT.PUT_LINE(V_ACCOUNTID || ' HAS SUFFICIENT AMOUNT');
    ELSE DBMS_OUTPUT.PUT_LINE(V_ACCOUNTID || ' DOES NOT HAVE SUFFICIENT AMOUNT');
    END IF;
END;
/

/*

Exercise 5: Triggers

Scenario 1: Automatically update the last modified date when a customer's record is updated.
        ? Question: Write a trigger UpdateCustomerLastModified that updates the LastModified column of the Customers 
            table to the current date whenever a customer's record is updated.
Scenario 2: Maintain an audit log for all transactions.
        ? Question: Write a trigger LogTransaction that inserts a record into an AuditLog table whenever a 
            transaction is inserted into the Transactions table.

Scenario 3: Enforce business rules on deposits and withdrawals.
        ? Question: Write a trigger CheckTransactionRules that ensures withdrawals do not exceed the balance and deposits 
            are positive before inserting a record into the Transactions table.

*/

-- SCENARIO 1

SELECT * FROM CUSTOMERS;

SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER UPDATECUSTOMERLASTMODIFIED
BEFORE UPDATE ON CUSTOMERS
FOR EACH ROW
BEGIN
    :NEW.LASTMODIFIED := SYSDATE;
    DBMS_OUTPUT.PUT_LINE('LAST MODIFIED UPDATED');
END UPDATECUSTOMERLASTMODIFIED;
/

UPDATE CUSTOMERS SET NAME = 'JOHN DOE' WHERE CUSTOMERID = 1;

-- SCENARIO 2

CREATE TABLE AUDITLOG (
    LOGID           NUMBER PRIMARY KEY,
    TRANSACTIONID   NUMBER,
    ACCOUNTID       NUMBER,
    TRANSACTIONDATE DATE,
    AMOUNT          NUMBER,
    TRANSACTIONTYPE VARCHAR2(10),
    LOGTIMESTAMP    DATE DEFAULT SYSDATE
);

SELECT * FROM TRANSACTIONS;

CREATE SEQUENCE AUDITLOG_SEQ 
START WITH 1 
INCREMENT BY 1;

SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER LOGTRANSACTIONS
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITLOG (LOGID, TRANSACTIONID, ACCOUNTID, TRANSACTIONDATE, AMOUNT, TRANSACTIONTYPE)
    VALUES (AUDITLOG_SEQ.NEXTVAL, :NEW.TRANSACTIONID, :NEW.ACCOUNTID, SYSDATE, :NEW.AMOUNT, :NEW.TRANSACTIONTYPE);
    DBMS_OUTPUT.PUT_LINE('INSERT SUCCESSFUL');
END LOGTRANSACTIONS;
/

INSERT INTO TRANSACTIONS (TRANSACTIONID, ACCOUNTID, TRANSACTIONDATE, AMOUNT, TRANSACTIONTYPE)
VALUES (6, 2, SYSDATE, 600, 'Deposit');

SELECT * FROM AUDITLOG;
SELECT * FROM TRANSACTIONS;

-- SCENARIO 3

SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER CHECKTRANSACTIONRULES
BEFORE INSERT ON TRANSACTIONS
FOR EACH ROW
DECLARE
    V_BALANCE ACCOUNTS.BALANCE%TYPE;
BEGIN
    -- Get the current balance of the account
    SELECT BALANCE INTO V_BALANCE
    FROM ACCOUNTS
    WHERE ACCOUNTID = :NEW.ACCOUNTID
    FOR UPDATE;

    -- Check the transaction type and validate accordingly
    IF :NEW.TRANSACTIONTYPE = 'Withdrawal' THEN
        IF :NEW.AMOUNT > V_BALANCE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient balance for the withdrawal.');
        END IF;
    ELSIF :NEW.TRANSACTIONTYPE = 'Deposit' THEN
        IF :NEW.AMOUNT <= 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Deposit amount must be positive.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Invalid transaction type.');
    END IF;
END CHECKTRANSACTIONRULES;
/

SELECT * FROM ACCOUNTS;
SELECT * FROM CUSTOMERS;

INSERT INTO ACCOUNTS (ACCOUNTID, CUSTOMERID, ACCOUNTTYPE, BALANCE, LASTMODIFIED)
VALUES (4, 1, 'Recurring', 3500, SYSDATE);

/*

Exercise 6: Cursors

Scenario 1: Generate monthly statements for all customers.
        ? Question: Write a PL/SQL block using an explicit cursor GenerateMonthlyStatements that retrieves all 
            transactions for the current month and prints a statement for each customer.
Scenario 2: Apply annual fee to all accounts.
        ? Question: Write a PL/SQL block using an explicit cursor ApplyAnnualFee that deducts an annual maintenance 
            fee from the balance of all accounts.
Scenario 3: Update the interest rate for all loans based on a new policy.
        ? Question: Write a PL/SQL block using an explicit cursor UpdateLoanInterestRates that fetches all loans and 
            updates their interest rates based on the new policy.

*/

-- SCENARIO 1

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUR_MONTHLY_TRANSACTIONS IS
        SELECT C.CUSTOMERID, C.NAME, T.TRANSACTIONDATE, T.AMOUNT, T.TRANSACTIONTYPE
        FROM CUSTOMERS C
        JOIN ACCOUNTS A ON C.CUSTOMERID = A.CUSTOMERID
        JOIN TRANSACTIONS T ON A.ACCOUNTID = T.ACCOUNTID
        WHERE TRUNC(T.TRANSACTIONDATE, 'MM') = TRUNC(SYSDATE, 'MM')
        ORDER BY C.CUSTOMERID, T.TRANSACTIONDATE;
        
    V_CUSTOMER_ID CUSTOMERS.CUSTOMERID%TYPE;
    V_CUSTOMER_NAME CUSTOMERS.NAME%TYPE;
    V_TRANSACTION_DATE TRANSACTIONS.TRANSACTIONDATE%TYPE;
    V_AMOUNT TRANSACTIONS.AMOUNT%TYPE;
    V_TRANSACTION_TYPE TRANSACTIONS.TRANSACTIONTYPE%TYPE;
BEGIN
    OPEN CUR_MONTHLY_TRANSACTIONS;
    
    LOOP
        FETCH CUR_MONTHLY_TRANSACTIONS INTO V_CUSTOMER_ID, V_CUSTOMER_NAME, V_TRANSACTION_DATE, V_AMOUNT, V_TRANSACTION_TYPE;
        EXIT WHEN CUR_MONTHLY_TRANSACTIONS%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || V_CUSTOMER_ID || ', Name: ' || V_CUSTOMER_NAME);
        DBMS_OUTPUT.PUT_LINE('Transaction Date: ' || TO_CHAR(V_TRANSACTION_DATE, 'YYYY-MM-DD') || ', Amount: ' || V_AMOUNT || ', Type: ' || V_TRANSACTION_TYPE);
    END LOOP;
    
    CLOSE CUR_MONTHLY_TRANSACTIONS;
END;
/

-- SCENARIO 2

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUR_ACCOUNTS IS
        SELECT ACCOUNTID, BALANCE
        FROM ACCOUNTS;
        
    V_ACCOUNT_ID ACCOUNTS.ACCOUNTID%TYPE;
    V_BALANCE ACCOUNTS.BALANCE%TYPE;
    V_ANNUAL_FEE CONSTANT NUMBER := 50; -- Annual fee amount
BEGIN
    OPEN CUR_ACCOUNTS;
    
    LOOP
        FETCH CUR_ACCOUNTS INTO V_ACCOUNT_ID, V_BALANCE;
        EXIT WHEN CUR_ACCOUNTS%NOTFOUND;
        
        UPDATE ACCOUNTS
        SET BALANCE = BALANCE - V_ANNUAL_FEE,
            LASTMODIFIED = SYSDATE
        WHERE ACCOUNTID = V_ACCOUNT_ID;
        
        DBMS_OUTPUT.PUT_LINE('Annual fee of ' || V_ANNUAL_FEE || ' deducted from Account ID: ' || V_ACCOUNT_ID);
    END LOOP;
    
    CLOSE CUR_ACCOUNTS;
    
    COMMIT;
END;
/

-- SCENARIO 3

SET SERVEROUTPUT ON;
DECLARE
    CURSOR CUR_LOANS IS
        SELECT LOANID, INTERESTRATE
        FROM LOANS;
        
    V_LOAN_ID LOANS.LOANID%TYPE;
    V_INTEREST_RATE LOANS.INTERESTRATE%TYPE;
    V_NEW_INTEREST_RATE NUMBER;
    V_NEW_POLICY NUMBER := 2;
    
    FUNCTION CALCULATENEWINTERESTRATE(OLD_RATE NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN OLD_RATE * (1 + (V_NEW_POLICY / 100)); 
    END CALCULATENEWINTERESTRATE;
BEGIN
    OPEN CUR_LOANS;
    
    LOOP
        FETCH CUR_LOANS INTO V_LOAN_ID, V_INTEREST_RATE;
        EXIT WHEN CUR_LOANS%NOTFOUND;
        
        V_NEW_INTEREST_RATE := CALCULATENEWINTERESTRATE(V_INTEREST_RATE);
        
        UPDATE LOANS
        SET INTERESTRATE = V_NEW_INTEREST_RATE
        WHERE LOANID = V_LOAN_ID;
        
        DBMS_OUTPUT.PUT_LINE('Loan ID: ' || V_LOAN_ID || ' interest rate updated to ' || V_NEW_INTEREST_RATE);
    END LOOP;
    
    CLOSE CUR_LOANS;
    
    COMMIT;
END;
/

/*

Exercise 7: Packages

Scenario 1: Group all customer-related procedures and functions into a package.
        ? Question: Create a package CustomerManagement with procedures for adding a new customer, 
            updating customer details, and a function to get customer balance.
Scenario 2: Create a package to manage employee data.
        ? Question: Write a package EmployeeManagement with procedures to hire new employees, update employee details, 
            and a function to calculate annual salary.
Scenario 3: Group all account-related operations into a package.
        ? Question: Create a package AccountOperations with procedures for opening a new account, closing an account, 
            and a function to get the total balance of a customer across all accounts.

*/

-- SCENARIO 1

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE CustomerManagement IS
    PROCEDURE AddNewCustomer(
        p_customer_id IN CUSTOMERS.CUSTOMERID%TYPE,
        p_name IN CUSTOMERS.NAME%TYPE,
        p_dob IN CUSTOMERS.DOB%TYPE,
        p_balance IN CUSTOMERS.BALANCE%TYPE
    );

    PROCEDURE UpdateCustomerDetails(
        p_customer_id IN CUSTOMERS.CUSTOMERID%TYPE,
        p_name IN CUSTOMERS.NAME%TYPE,
        p_dob IN CUSTOMERS.DOB%TYPE,
        p_balance IN CUSTOMERS.BALANCE%TYPE
    );

    FUNCTION GetCustomerBalance(
        p_customer_id IN CUSTOMERS.CUSTOMERID%TYPE
    ) RETURN CUSTOMERS.BALANCE%TYPE;
END CustomerManagement;
/

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE BODY CUSTOMERMANAGEMENT IS

    PROCEDURE ADDNEWCUSTOMER(
        P_CUSTOMER_ID IN CUSTOMERS.CUSTOMERID%TYPE,
        P_NAME IN CUSTOMERS.NAME%TYPE,
        P_DOB IN CUSTOMERS.DOB%TYPE,
        P_BALANCE IN CUSTOMERS.BALANCE%TYPE
    ) IS
    BEGIN
        INSERT INTO CUSTOMERS (CUSTOMERID, NAME, DOB, BALANCE, LASTMODIFIED)
        VALUES (P_CUSTOMER_ID, P_NAME, P_DOB, P_BALANCE, SYSDATE);
    END ADDNEWCUSTOMER;

    PROCEDURE UPDATECUSTOMERDETAILS(
        P_CUSTOMER_ID IN CUSTOMERS.CUSTOMERID%TYPE,
        P_NAME IN CUSTOMERS.NAME%TYPE,
        P_DOB IN CUSTOMERS.DOB%TYPE,
        P_BALANCE IN CUSTOMERS.BALANCE%TYPE
    ) IS
    BEGIN
        UPDATE CUSTOMERS
        SET NAME = P_NAME,
            DOB = P_DOB,
            BALANCE = P_BALANCE,
            LASTMODIFIED = SYSDATE
        WHERE CUSTOMERID = P_CUSTOMER_ID;
    END UPDATECUSTOMERDETAILS;

    FUNCTION GETCUSTOMERBALANCE(
        P_CUSTOMER_ID IN CUSTOMERS.CUSTOMERID%TYPE
    ) RETURN CUSTOMERS.BALANCE%TYPE IS
        V_BALANCE CUSTOMERS.BALANCE%TYPE;
    BEGIN
        SELECT BALANCE INTO V_BALANCE
        FROM CUSTOMERS
        WHERE CUSTOMERID = P_CUSTOMER_ID;
        RETURN V_BALANCE;
    END GETCUSTOMERBALANCE;

END CUSTOMERMANAGEMENT;
/

-- SCENARIO 2

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE EMPLOYEEMANAGEMENT IS
    PROCEDURE HIREEMPLOYEE(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE,
        P_NAME IN EMPLOYEES.NAME%TYPE,
        P_POSITION IN EMPLOYEES.POSITION%TYPE,
        P_SALARY IN EMPLOYEES.SALARY%TYPE,
        P_DEPARTMENT IN EMPLOYEES.DEPARTMENT%TYPE,
        P_HIRE_DATE IN EMPLOYEES.HIREDATE%TYPE
    );

    PROCEDURE UPDATEEMPLOYEEDETAILS(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE,
        P_NAME IN EMPLOYEES.NAME%TYPE,
        P_POSITION IN EMPLOYEES.POSITION%TYPE,
        P_SALARY IN EMPLOYEES.SALARY%TYPE,
        P_DEPARTMENT IN EMPLOYEES.DEPARTMENT%TYPE
    );

    FUNCTION CALCULATEANNUALSALARY(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE
    ) RETURN NUMBER;
END EMPLOYEEMANAGEMENT;
/

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE BODY EMPLOYEEMANAGEMENT IS

    PROCEDURE HIREEMPLOYEE(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE,
        P_NAME IN EMPLOYEES.NAME%TYPE,
        P_POSITION IN EMPLOYEES.POSITION%TYPE,
        P_SALARY IN EMPLOYEES.SALARY%TYPE,
        P_DEPARTMENT IN EMPLOYEES.DEPARTMENT%TYPE,
        P_HIRE_DATE IN EMPLOYEES.HIREDATE%TYPE
    ) IS
    BEGIN
        INSERT INTO EMPLOYEES (EMPLOYEEID, NAME, POSITION, SALARY, DEPARTMENT, HIREDATE)
        VALUES (P_EMPLOYEE_ID, P_NAME, P_POSITION, P_SALARY, P_DEPARTMENT, P_HIRE_DATE);
    END HIREEMPLOYEE;

    PROCEDURE UPDATEEMPLOYEEDETAILS(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE,
        P_NAME IN EMPLOYEES.NAME%TYPE,
        P_POSITION IN EMPLOYEES.POSITION%TYPE,
        P_SALARY IN EMPLOYEES.SALARY%TYPE,
        P_DEPARTMENT IN EMPLOYEES.DEPARTMENT%TYPE
    ) IS
    BEGIN
        UPDATE EMPLOYEES
        SET NAME = P_NAME,
            POSITION = P_POSITION,
            SALARY = P_SALARY,
            DEPARTMENT = P_DEPARTMENT
        WHERE EMPLOYEEID = P_EMPLOYEE_ID;
    END UPDATEEMPLOYEEDETAILS;

    FUNCTION CALCULATEANNUALSALARY(
        P_EMPLOYEE_ID IN EMPLOYEES.EMPLOYEEID%TYPE
    ) RETURN NUMBER IS
        V_SALARY EMPLOYEES.SALARY%TYPE;
    BEGIN
        SELECT SALARY INTO V_SALARY
        FROM EMPLOYEES
        WHERE EMPLOYEEID = P_EMPLOYEE_ID;
        RETURN V_SALARY * 12; -- Assuming salary is monthly
    END CALCULATEANNUALSALARY;

END EMPLOYEEMANAGEMENT;
/

-- SCENARIO 3

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE ACCOUNTOPERATIONS IS
    PROCEDURE OPENNEWACCOUNT(
        P_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
        P_CUSTOMER_ID IN ACCOUNTS.CUSTOMERID%TYPE,
        P_ACCOUNT_TYPE IN ACCOUNTS.ACCOUNTTYPE%TYPE,
        P_BALANCE IN ACCOUNTS.BALANCE%TYPE
    );

    PROCEDURE CLOSEACCOUNT(
        P_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE
    );

    FUNCTION GETTOTALBALANCE(
        P_CUSTOMER_ID IN ACCOUNTS.CUSTOMERID%TYPE
    ) RETURN NUMBER;
END ACCOUNTOPERATIONS;
/

SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE BODY ACCOUNTOPERATIONS IS

    PROCEDURE OPENNEWACCOUNT(
        P_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE,
        P_CUSTOMER_ID IN ACCOUNTS.CUSTOMERID%TYPE,
        P_ACCOUNT_TYPE IN ACCOUNTS.ACCOUNTTYPE%TYPE,
        P_BALANCE IN ACCOUNTS.BALANCE%TYPE
    ) IS
    BEGIN
        INSERT INTO ACCOUNTS (ACCOUNTID, CUSTOMERID, ACCOUNTTYPE, BALANCE, LASTMODIFIED)
        VALUES (P_ACCOUNT_ID, P_CUSTOMER_ID, P_ACCOUNT_TYPE, P_BALANCE, SYSDATE);
    END OPENNEWACCOUNT;

    PROCEDURE CLOSEACCOUNT(
        P_ACCOUNT_ID IN ACCOUNTS.ACCOUNTID%TYPE
    ) IS
    BEGIN
        DELETE FROM ACCOUNTS
        WHERE ACCOUNTID = P_ACCOUNT_ID;
    END CLOSEACCOUNT;

    FUNCTION GETTOTALBALANCE(
        P_CUSTOMER_ID IN ACCOUNTS.CUSTOMERID%TYPE
    ) RETURN NUMBER IS
        V_TOTAL_BALANCE NUMBER;
    BEGIN
        SELECT SUM(BALANCE) INTO V_TOTAL_BALANCE
        FROM ACCOUNTS
        WHERE CUSTOMERID = P_CUSTOMER_ID;
        RETURN V_TOTAL_BALANCE;
    END GETTOTALBALANCE;

END ACCOUNTOPERATIONS;
/