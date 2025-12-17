WITH nums AS (
    SELECT TOP (200)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)

-- insert the values into the customer table
INSERT INTO customers ([name], gender, dob, signup_date, city)
SELECT
    fn.v + ' ' + ln.v AS name,
    CASE WHEN ABS(CHECKSUM(NEWID(), nums.n)) % 2 = 0 THEN 'M' ELSE 'F' END AS gender,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID(), nums.n)) % 10000, '1997-01-01') AS dob,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID(), nums.n)) % 1095, CAST(GETDATE() AS DATE)) AS signup_date,
    ct.v AS city
FROM nums
CROSS APPLY (
    SELECT TOP 1 v
    FROM (VALUES
        ('Chinedu'),('Aisha'),('Tunde'),('Ngozi'),('Bola'),('Obinna'),
        ('Fatima'),('Yakubu'),('Emeka'),('Zainab'),('Ifeanyi'),('Uche'),
        ('Abubakar'),('Lilian'),('Segun'),('Halima'),
        ('Adesuwa'),('Kehinde'),('Mercy'),('Emmanuel')
    ) a(v)
    ORDER BY CHECKSUM(NEWID(), nums.n)
) fn
CROSS APPLY (
    SELECT TOP 1 v
    FROM (VALUES
        ('Okonkwo'),('Balogun'),('Adegoke'),('Nwachukwu'),('Danjuma'),
        ('Adelaja'),('Ibrahim'),('Umeh'),('Ogunleye'),('Abiola'),
        ('Mohammed'),('Eze'),('Lawal'),('Obi'),('Ahmed'),('Onyeka'),
        ('Nwabueze'),('Ajibade'),('Suleman'),('Johnson')
    ) b(v)
    ORDER BY CHECKSUM(NEWID(), nums.n)
) ln
CROSS APPLY (
    SELECT TOP 1 v
    FROM (VALUES
        ('Lagos'),('Abuja'),('Port Harcourt'),('Enugu'),
        ('Kano'),('Ibadan'),('Jos'),('Abeokuta'),
        ('Calabar'),('Owerri'),('Benin City'),('Kaduna')
    ) c(v)
    ORDER BY CHECKSUM(NEWID(), nums.n)
) ct;

WITH account_candidates AS (
    SELECT c.customer_id
    FROM customers c
    CROSS JOIN (VALUES (1),(2)) g(n)
),
filtered_accounts AS (
    SELECT customer_id
    FROM account_candidates
    WHERE ABS(CHECKSUM(NEWID(), customer_id)) % 100 < 75
)

--insert the values into the accounts table
INSERT INTO accounts (
    customer_id, account_number, account_type, open_date, balance
)
SELECT
    fa.customer_id,
    RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID(), fa.customer_id)) % 10000000000 AS VARCHAR(10)), 10) AS account_number,
    CHOOSE(ABS(CHECKSUM(NEWID(), fa.customer_id)) % 3 + 1, 'savings','current','loan') AS account_type,
    DATEADD(DAY, ABS(CHECKSUM(NEWID(), fa.customer_id)) % 90, c.signup_date) AS open_date,
    ROUND(1000 + (ABS(CHECKSUM(NEWID(), fa.customer_id)) % 499000), 2) AS balance
FROM filtered_accounts fa
JOIN customers c
    ON c.customer_id = fa.customer_id;

IF OBJECT_ID('tempdb..#txn_pool') IS NOT NULL DROP TABLE #txn_pool;

SELECT
    a.account_id                         AS account_id,
    CASE 
        WHEN ABS(CHECKSUM(NEWID(), a.account_id)) % 2 = 0 
        THEN 'credit' ELSE 'debit' 
    END                                  AS transaction_type,
    ROUND(500 + (ABS(CHECKSUM(NEWID(), a.account_id)) % 249500), 2)
                                         AS amount,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID(), a.account_id)) % 730, CAST(GETDATE() AS DATE))
                                         AS transaction_date,
    CAST(NULL AS VARCHAR(50))             AS description
INTO #txn_pool
FROM accounts a
CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) g(n);
UPDATE p
SET description =
    CASE 
        WHEN transaction_type = 'credit' THEN
            CHOOSE(ABS(CHECKSUM(NEWID(), account_id)) % 11 + 1,
                'Salary credited','Bank transfer from GTBank','Credit alert from Zenith',
                'Reversal of failed transaction','Loan disbursement','Wallet top-up',
                'Refund from vendor','POS reversal','Received from customer',
                'Online payment received','Cash deposit')
        ELSE
            CHOOSE(ABS(CHECKSUM(NEWID(), account_id)) % 11 + 1,
                'POS payment at Shoprite','MTN Airtime recharge','Fuel purchase at Mobil',
                'Electricity bill payment','Loan EMI debit','House rent payment',
                'Online purchase at Jumia','Cash withdrawal from ATM',
                'Subscription payment','Insurance premium debit',
                'Bank transfer to Fidelity Bank')
    END
FROM #txn_pool p;

-- insert the values into the transactions table
INSERT INTO transactions (
    account_id, transaction_type, amount, transaction_date, description
)
SELECT TOP (1000)
    account_id, transaction_type, amount, transaction_date, description
FROM #txn_pool
ORDER BY NEWID();

SELECT COUNT(*) FROM customers;    
SELECT COUNT(*) FROM accounts;      
SELECT COUNT(*) FROM transactions;  
