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

--
