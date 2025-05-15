SELECT 
*
FROM DBO.products;

-- ------------------------------

-- QUERY TO CATEGORIZE PRODUCTS BASED ON THEIR PRICE: 
SELECT 
	ProductID,
	ProductName,
	Price,
CASE 
	WHEN Price < 50 THEN 'Low'
	WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
	ELSE 'High'
END AS PriceCategory
FROM dbo.products;
-- -------------------------------
SELECT * 
FROM customers;

SELECT * 
FROM geography;

-- SQL statement to join dim_customers with dim_geography to enrich customer data with geographic information

SELECT 
    c.CustomerID, 
    c.CustomerName,  
    c.Email,  
    c.Gender,  
    c.Age,  
    g.Country,  
    g.City  
FROM 
    dbo.customers as c  
LEFT JOIN
-- RIGHT JOIN
-- INNER JOIN
-- FULL OUTER JOIN
    dbo.geography g 
ON 
    c.GeographyID = g.GeographyID; 

-- ------------------------------

SELECT * 
FROM 
DBO.customer_reviews;




-- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized
SELECT 
    ReviewID,  
    CustomerID,  
    ProductID,  
    ReviewDate,  
    Rating,  
    
    REPLACE(ReviewText, '  ', ' ') AS ReviewText
FROM 
    dbo.customer_reviews;
-- ------------------------------
SELECT * 
FROM engagement_data;

SELECT 
	engagementID,
	ContentID,
	CampaignID,
	ProductID,
	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,  
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,  
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks, 
    Likes,  
    FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate  -- Converts and formats the date as dd.mm.yyyy
FROM 
    dbo.engagement_data  -- Specifies the source table from which to select the data
WHERE 
    ContentType != 'Newsletter';  -- Filters out rows where ContentType is 'Newsletter' as these are not relevant for our analysis

-- -----------------------------
SELECT *
FROM customer_journey ORDER BY VisitDate;

SELECT * , AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration
FROM 
DBO.customer_journey ORDER BY VisitDate; 

Select * 
from customer_journey 
where Duration is null;

WITH DuplicateRecords AS (
    SELECT 
        JourneyID, 
        CustomerID,  
        ProductID,  
        VisitDate,  
        Stage, 
        Action,
        Duration, 
        ROW_NUMBER() OVER (
            
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action  
            
            ORDER BY JourneyID  
        ) AS row_num  
    FROM 
        dbo.customer_journey  
)
SELECT *
FROM DuplicateRecords
WHERE row_num > 1 
ORDER BY JourneyID




-- Outer query selects the final cleaned and standardized data
    
SELECT 
    JourneyID,  
    CustomerID, 
    ProductID, 
    VisitDate,  
    Stage,  
    Action,  
    COALESCE(Duration, avg_duration) AS Duration  
FROM 
    (
        -- Subquery to process and clean the data
        SELECT 
            JourneyID, 
            CustomerID, 
            ProductID,  
            VisitDate,  
            UPPER(Stage) AS Stage,  
            Action,  
            Duration,  
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action  
                ORDER BY JourneyID  
            ) AS row_num  
        FROM 
            dbo.customer_journey  
    ) AS subquery  
WHERE 
    row_num = 1;  

	   	  