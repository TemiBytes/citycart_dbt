-- Snowflake setup script (run in Snowsight / worksheet)
/*Run this first in a Snowflake worksheet (using role SYSADMIN to create objects): */

------------------------------------------------------------
-- 0. Use / create database + schemas
------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS CITYCART_RAW;
USE DATABASE CITYCART_RAW;

CREATE SCHEMA IF NOT EXISTS RAW_APP;
CREATE SCHEMA IF NOT EXISTS RAW_OPS;
CREATE SCHEMA IF NOT EXISTS RAW_MKT;
CREATE SCHEMA IF NOT EXISTS RAW_SUPPORT;

------------------------------------------------------------
-- 1. Common CSV FILE FORMAT (reusable for all loads)
------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT FF_CITYCART_CSV
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
    NULL_IF = ('', 'NULL');

------------------------------------------------------------
-- 2. Internal STAGES (for uploading from your laptop)
------------------------------------------------------------

-- RAW_APP
CREATE OR REPLACE STAGE RAW_APP.STG_CITYCART_RAW_APP
    FILE_FORMAT = FF_CITYCART_CSV;

-- RAW_OPS
CREATE OR REPLACE STAGE RAW_OPS.STG_CITYCART_RAW_OPS
    FILE_FORMAT = FF_CITYCART_CSV;

-- RAW_MKT
CREATE OR REPLACE STAGE RAW_MKT.STG_CITYCART_RAW_MKT
    FILE_FORMAT = FF_CITYCART_CSV;

-- RAW_SUPPORT
CREATE OR REPLACE STAGE RAW_SUPPORT.STG_CITYCART_RAW_SUPPORT
    FILE_FORMAT = FF_CITYCART_CSV;

------------------------------------------------------------
-- 3. TABLES
------------------------------------------------------------

-------------------------
-- RAW_APP tables
-------------------------
USE SCHEMA RAW_APP;

CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id STRING,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone_number STRING,
    signup_date TIMESTAMP_NTZ,
    signup_channel STRING,
    city STRING,
    country STRING,
    birth_date DATE,
    gender STRING,
    is_premium BOOLEAN,
    deleted_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE PRODUCTS (
    product_id STRING,
    product_sku STRING,
    product_name STRING,
    category STRING,
    sub_category STRING,
    brand STRING,
    unit_of_measure STRING,
    standard_price NUMBER(10,2),
    cost_price NUMBER(10,2),
    is_active BOOLEAN,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ORDERS (
    order_id STRING,
    customer_id STRING,
    order_datetime TIMESTAMP_NTZ,
    order_status STRING,
    payment_method STRING,
    city STRING,
    country STRING,
    device_type STRING,
    promo_code STRING,
    subtotal_amount NUMBER(12,2),
    discount_amount NUMBER(12,2),
    delivery_fee NUMBER(12,2),
    tip_amount NUMBER(12,2),
    total_amount NUMBER(12,2),
    currency STRING,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ORDER_ITEMS (
    order_item_id STRING,
    order_id STRING,
    product_id STRING,
    quantity NUMBER(10,0),
    unit_price NUMBER(10,2),
    line_subtotal NUMBER(12,2),
    line_discount NUMBER(12,2),
    line_total NUMBER(12,2),
    created_at TIMESTAMP_NTZ
);

-------------------------
-- RAW_OPS tables
-------------------------
USE SCHEMA RAW_OPS;

CREATE OR REPLACE TABLE DRIVERS (
  driver_id        STRING,
  first_name       STRING,
  last_name        STRING,
  phone_number     STRING,
  city             STRING,
  country          STRING,
  vehicle_type     STRING,
  employment_type  STRING,
  start_date       DATE,
  end_date         DATE
);

CREATE OR REPLACE TABLE WAREHOUSES (
  warehouse_id   STRING,
  city           STRING,
  country        STRING,
  latitude       NUMBER(10,6),
  longitude      NUMBER(10,6),
  warehouse_name STRING,
  is_active      BOOLEAN,
  opened_at      DATE,
  closed_at      DATE
);

CREATE OR REPLACE TABLE DELIVERIES (
  delivery_id                STRING,
  order_id                   STRING,
  driver_id                  STRING,
  pickup_warehouse_id        STRING,
  delivery_status            STRING,
  pickup_time                TIMESTAMP_NTZ,
  out_for_delivery_time      TIMESTAMP_NTZ,
  delivered_time             TIMESTAMP_NTZ,
  cancelled_time             TIMESTAMP_NTZ,
  distance_km                NUMBER(10,2),
  estimated_delivery_minutes NUMBER(10,2),
  actual_delivery_minutes    NUMBER(10,2),
  failure_reason             STRING
);

-------------------------
-- RAW_MKT tables
-------------------------
USE SCHEMA RAW_MKT;

CREATE OR REPLACE TABLE CAMPAIGNS (
  campaign_id          STRING,
  campaign_name        STRING,
  channel              STRING,
  country              STRING,
  campaign_start_date  DATE,
  campaign_end_date    DATE,
  budget_usd           NUMBER(14,2),
  objective            STRING
);

CREATE OR REPLACE TABLE CAMPAIGN_ATTRIBUTIONS (
  order_id           STRING,
  campaign_id        STRING,
  attribution_model  STRING,
  attribution_weight NUMBER(5,2)
);

-------------------------
-- RAW_SUPPORT tables
-------------------------
USE SCHEMA RAW_SUPPORT;

CREATE OR REPLACE TABLE TICKETS (
  ticket_id               STRING,
  customer_id             STRING,
  order_id                STRING,
  ticket_created_at       TIMESTAMP_NTZ,
  ticket_status           STRING,
  category                STRING,
  resolution_time_minutes NUMBER(10,2),
  csat_score              NUMBER(3,1),
  notes                   STRING
);







----------------------------
---- SnowSQL script: PUT + COPY from your laptop
----------------------------

-- upload csvs into internal stages (PUT)
/* Run these at the snowsql prompt*/

-- RAW_APP files -> RAW_APP.STG_CITYCART_RAW_APP
PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\customers.csv
  @CITYCART_RAW.RAW_APP.STG_CITYCART_RAW_APP
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\products.csv
  @CITYCART_RAW.RAW_APP.STG_CITYCART_RAW_APP
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\orders.csv
  @CITYCART_RAW.RAW_APP.STG_CITYCART_RAW_APP
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\order_items.csv
  @CITYCART_RAW.RAW_APP.STG_CITYCART_RAW_APP
  AUTO_COMPRESS = FALSE;


-- RAW_OPS files -> RAW_OPS.STG_CITYCART_RAW_OPS
PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\drivers.csv
  @CITYCART_RAW.RAW_OPS.STG_CITYCART_RAW_OPS
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\warehouses.csv
  @CITYCART_RAW.RAW_OPS.STG_CITYCART_RAW_OPS
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\deliveries.csv
  @CITYCART_RAW.RAW_OPS.STG_CITYCART_RAW_OPS
  AUTO_COMPRESS = FALSE;


-- RAW_MKT files -> RAW_MKT.STG_CITYCART_RAW_MKT
PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\campaigns.csv
  @CITYCART_RAW.RAW_MKT.STG_CITYCART_RAW_MKT
  AUTO_COMPRESS = FALSE;

PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\campaign_attributions.csv
  @CITYCART_RAW.RAW_MKT.STG_CITYCART_RAW_MKT
  AUTO_COMPRESS = FALSE;


-- RAW_SUPPORT files -> RAW_SUPPORT.STG_CITYCART_RAW_SUPPORT
PUT file://C:\Workspace\Data_Projects\citycart_dbt\data_raw\tickets.csv
  @CITYCART_RAW.RAW_SUPPORT.STG_CITYCART_RAW_SUPPORT
  AUTO_COMPRESS = FALSE;



-- COPY data from stages into raw tables (COPY INTO)

------------------------------------------------------------
-- RAW_APP
------------------------------------------------------------
USE DATABASE CITYCART_RAW;
USE SCHEMA RAW_APP;

COPY INTO CUSTOMERS
FROM @STG_CITYCART_RAW_APP/customers.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO PRODUCTS
FROM @STG_CITYCART_RAW_APP/products.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO ORDERS
FROM @STG_CITYCART_RAW_APP/orders.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO ORDER_ITEMS
FROM @STG_CITYCART_RAW_APP/order_items.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

------------------------------------------------------------
-- RAW_OPS
------------------------------------------------------------
USE SCHEMA RAW_OPS;

COPY INTO DRIVERS
FROM @STG_CITYCART_RAW_OPS/drivers.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO WAREHOUSES
FROM @STG_CITYCART_RAW_OPS/warehouses.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO DELIVERIES
FROM @STG_CITYCART_RAW_OPS/deliveries.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

------------------------------------------------------------
-- RAW_MKT
------------------------------------------------------------
USE SCHEMA RAW_MKT;

COPY INTO CAMPAIGNS
FROM @STG_CITYCART_RAW_MKT/campaigns.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

COPY INTO CAMPAIGN_ATTRIBUTIONS
FROM @STG_CITYCART_RAW_MKT/campaign_attributions.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);

------------------------------------------------------------
-- RAW_SUPPORT
------------------------------------------------------------
USE SCHEMA RAW_SUPPORT;

COPY INTO TICKETS
FROM @STG_CITYCART_RAW_SUPPORT/tickets.csv
FILE_FORMAT = (FORMAT_NAME = FF_CITYCART_CSV);
------------------------------------------------------------