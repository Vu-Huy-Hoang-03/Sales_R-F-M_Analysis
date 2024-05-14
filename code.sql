-- 1. Creating Table & Import Data --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table SALES_DATASET_RFM_PRJ
(
  ordernumber VARCHAR,
  quantityordered VARCHAR,
  priceeach        VARCHAR,
  orderlinenumber  VARCHAR,
  sales            VARCHAR,
  orderdate        VARCHAR,
  status           VARCHAR,
  productline      VARCHAR,
  msrp             VARCHAR,
  productcode      VARCHAR,
  customername     VARCHAR,
  phone            VARCHAR,
  addressline1     VARCHAR,
  addressline2     VARCHAR,
  city             VARCHAR,
  state            VARCHAR,
  postalcode       VARCHAR,
  country          VARCHAR,
  territory        VARCHAR,
  contactfullname  VARCHAR,
  dealsize         VARCHAR
) 

ALTER TABLE SALES_DATASET_RFM_PRJ
	ALTER COLUMN ordernumber TYPE INT USING(ordernumber::integer),
	ALTER COLUMN quantityordered TYPE SMALLINT USING(quantityordered::smallint),
	ALTER COLUMN priceeach TYPE DECIMAL USING(priceeach::decimal),
	ALTER COLUMN orderlinenumber TYPE SMALLINT USING(orderlinenumber::smallint),
	ALTER COLUMN sales TYPE DECIMAL USING(sales::decimal),
	ALTER COLUMN msrp TYPE SMALLINT USING(msrp::smallint),
  ALTER COLUMN contactfullname TYPE TEXT

-- 2. Data Cleaning -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NULL values
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE	ordernumber IS NULL
	OR quantityordered IS NULL
	OR priceeach IS NULL
	OR orderlinenumber IS NULL
	OR sales IS NULL
	OR orderdate IS NULL

-- Duplicate values


-- Outlier: Using Box-Plot method
WITH B1 AS (
SELECT	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered)
		- PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
FROM SALES_DATASET_RFM_PRJ
)

, B2 AS (
SELECT	(Q1-1.5*IQR) AS min,
		(Q3+1.5*IQR) AS max
FROM B1
)

DELETE FROM SALES_DATASET_RFM_PRJ
WHERE 	quantityordered < (SELECT min FROM B2)
		OR quantityordered > (SELECT max FROM B2)

CREATE TABLE sales_dataset_rfm_prj_clean
AS( SELECT * FROM SALES_DATASET_RFM_PRJ )

-- 3. R-F-M Analysis ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step1: Calculate R, F, M points
WITH B_1 AS (
SELECT	customername,
		current_date - MAX(orderdate) as R,
		COUNT(ordernumber) as F,
		SUM(sales) as M
FROM public.sales_dataset_rfm_prj_clean
GROUP BY customername
)
-- Step2: divide R, F, M points into 5 levels
, B_2 AS (
SELECT	customername,
		NTILE(5) OVER(ORDER BY R DESC) as R,
		NTILE(5) OVER(ORDER BY F) as F,
		NTILE(5) OVER(ORDER BY M) as M
FROM B_1
)
-- Step3: CONCAT(R,F,M)
, B_3 AS (
SELECT 	customername,
		CONCAT(r,f,m) as RFM
FROM B_2
)
-- Step4: Segmentation
SELECT	a.customername, a.rfm, b.segment
FROM B_3 as a
INNER JOIN segment_score as b
	ON a.rfm = b.scores


