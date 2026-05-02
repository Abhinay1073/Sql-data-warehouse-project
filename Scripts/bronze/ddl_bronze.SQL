EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze   -- Create if not exists, otherwise update
AS
BEGIN

DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;  -- Variables to track load time

BEGIN TRY   -- Start error handling block
set @batch_start_time = GETDATE();

PRINT '==================================================';  -- Header line
PRINT 'Load Bronze Layer';                                -- Process name
PRINT '==================================================';

------------------- CRM -------------------

PRINT 'Loading CRM Tables';   -- Section indicator

-- Customer Info
TRUNCATE TABLE bronze.crm_cust_info;   -- Remove old data (full refresh in Bronze)

SET @start_time = GETDATE();   -- Capture start time

BULK INSERT bronze.crm_cust_info   -- Load data into table
FROM 'C:\SQLData\cust_info.csv'   -- Source file path
WITH (
    FIRSTROW = 2,                 -- Skip header row
    FIELDTERMINATOR = ',',       -- Columns separated by comma
     
    TABLOCK                      -- Improves bulk insert performance
);

SET @end_time = GETDATE();   -- Capture end time

PRINT 'CRM Cust Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';   -- Print duration in seconds

-------------------------------------------------

-- Product Info
TRUNCATE TABLE bronze.crm_prd_info;   -- Clear existing data

SET @start_time = GETDATE();   -- Start time

BULK INSERT bronze.crm_prd_info
FROM 'C:\SQLData\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    
    TABLOCK
);

SET @end_time = GETDATE();   -- End time

PRINT 'CRM Product Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';

-------------------------------------------------

-- Sales Details
TRUNCATE TABLE bronze.crm_sales_details;   -- Clear old sales data

SET @start_time = GETDATE();   -- Start timer

BULK INSERT bronze.crm_sales_details
FROM 'C:\SQLData\sales_details.csv'   -- Correct file for sales
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
   
    TABLOCK
);

SET @end_time = GETDATE();   -- End timer

PRINT 'CRM Sales Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';

------------------- ERP -------------------

PRINT 'Loading ERP Tables';   -- Section indicator

-- ERP Customer
TRUNCATE TABLE bronze.erp_cust_az12;   -- Clear existing data

SET @start_time = GETDATE();   -- Start time

BULK INSERT bronze.erp_cust_az12
FROM 'C:\SQLData\CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    
    TABLOCK
);

SET @end_time = GETDATE();   -- End time

PRINT 'ERP Cust Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';

-------------------------------------------------

-- Location Table
TRUNCATE TABLE bronze.erp_loc_a101;   -- Clear old data

SET @start_time = GETDATE();   -- Start time

BULK INSERT bronze.erp_loc_a101
FROM 'C:\SQLData\LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    
    TABLOCK
);

SET @end_time = GETDATE();   -- End time

PRINT 'ERP Location Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';

-------------------------------------------------

-- Category Table
TRUNCATE TABLE bronze.erp_px_cat_g1v2;   -- Clear old data

SET @start_time = GETDATE();   -- Start time

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\SQLData\PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    
    TABLOCK
);

SET @end_time = GETDATE();   -- End time

SET @batch_end_time=GETDATE();

PRINT 'ERP Category Load Time: ' 
+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) 
+ ' sec';

-------------------------------------------------

END TRY   -- End of main logic

BEGIN CATCH   -- Error handling block
    PRINT '=============================================';  
    PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';  
    PRINT ERROR_MESSAGE();   -- Show actual SQL error
    PRINT '=============================================';
END CATCH

END;
