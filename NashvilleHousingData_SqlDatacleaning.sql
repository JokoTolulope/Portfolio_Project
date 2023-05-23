SELECT *
FROM [dbo].[Nashville_Housing_data]

--Standardize date format in the SaleDate column
SELECT SaleDate, CAST(SaleDate as Date)
FROM [dbo].[Nashville_Housing_data]

UPDATE [dbo].[Nashville_Housing_data] --it didnt update the saledate column in the table to the newly converted date type as specified in the query
SET SaleDate = CAST(SaleDate as Date)

ALTER TABLE [dbo].[Nashville_Housing_data] --so i tried creating a new column entirely for the converted sale date
ADD SaleDateConverted Date

UPDATE [dbo].[Nashville_Housing_data] --then i updated the empty new column created with the formatted date type, so we have the SaleDate in the correct date type format in the SaleDateConverted column
SET SaleDateConverted = CAST(SaleDate as Date)

--Populating the property address column to fix the null rows
SELECT [PropertyAddress]
FROM [dbo].[Nashville_Housing_data]

SELECT [PropertyAddress]
FROM [dbo].[Nashville_Housing_data]
WHERE [PropertyAddress] IS NULL

SELECT *
FROM [dbo].[Nashville_Housing_data]
WHERE [PropertyAddress] IS NULL

SELECT * --Some Parcelid were repeated and some of the duplicate parcelid has a null value in the property address column
FROM [dbo].[Nashville_Housing_data]
--WHERE [PropertyAddress] IS NULL
ORDER BY [ParcelID]

--so we use join to join the table to itself and fill up the null values with the existing address in the duplicate parcelid row
SELECT a.[ParcelID], a.[PropertyAddress], a.[UniqueID ], b.[ParcelID], b.[PropertyAddress], b.[UniqueID ], COALESCE(a.[PropertyAddress], b.[PropertyAddress])
FROM [dbo].[Nashville_Housing_data] AS a
JOIN [dbo].[Nashville_Housing_data] AS b
    ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.[PropertyAddress] IS NULL

--the above query will not permanently chage the property address in the table, the query will only work for the result it will populate when executed
--so we have to update the property address with the new column generated to properly fix the null in the property address column in the table permanently
UPDATE a
SET [PropertyAddress] = COALESCE(a.[PropertyAddress], b.[PropertyAddress])
FROM [dbo].[Nashville_Housing_data] AS a
JOIN [dbo].[Nashville_Housing_data] AS b
    ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.[PropertyAddress] IS NULL

SELECT *
FROM [dbo].[Nashville_Housing_data] --Shows there are no more null rows in the property address column
WHERE [PropertyAddress] IS NULL

SELECT [PropertyAddress]
FROM [dbo].[Nashville_Housing_data]
WHERE [PropertyAddress] IS NOT NULL

--Separating address column into separate columns (Address, City, State)
SELECT [PropertyAddress]
FROM [dbo].[Nashville_Housing_data]

SELECT [PropertyAddress], 
       SUBSTRING([PropertyAddress],1, CHARINDEX(',', [PropertyAddress])-1) AS PropertySplitAddress
FROM [dbo].[Nashville_Housing_data] --Charindex is used to select the position no of the delimeter(, in this case) 

SELECT [PropertyAddress],
       SUBSTRING([PropertyAddress],1, CHARINDEX(',', [PropertyAddress])-1) AS PropertySplitAddress,
	   SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress])+1, LEN([PropertyAddress])) AS PropertySplitCity
FROM [dbo].[Nashville_Housing_data]

--Creating new columns for the splitted address and city and also updating the new column with the splitted information
ALTER TABLE [dbo].[Nashville_Housing_data]
ADD PropertySplitAddress Nvarchar(255)

UPDATE [dbo].[Nashville_Housing_data]
SET PropertySplitAddress = SUBSTRING([PropertyAddress],1, CHARINDEX(',', [PropertyAddress])-1)

ALTER TABLE [dbo].[Nashville_Housing_data]
ADD PropertySplitCity Nvarchar(255)

UPDATE [dbo].[Nashville_Housing_data]
SET PropertySplitCity = SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress])+1, LEN([PropertyAddress]))

SELECT *
FROM [dbo].[Nashville_Housing_data]

--Splitting the Owner Address column using PARSENAME and REPLACE
SELECT [OwnerName]
FROM [dbo].[Nashville_Housing_data]

SELECT [OwnerAddress],
       PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3) AS OwnerSplitAddress, 
	   PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2) AS OwnerSplitCity,
	   PARSENAME(REPLACE([OwnerAddress], ',', '.') ,1) AS OwnerSplitState
FROM [dbo].[Nashville_Housing_data]

--Creating new columns to accomodate the splitted strings
ALTER TABLE [dbo].[Nashville_Housing_data]
ADD OwnerSplitAddress Nvarchar(255)

UPDATE [dbo].[Nashville_Housing_data]
SET OwnerSplitAddress = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3)

ALTER TABLE [dbo].[Nashville_Housing_data]
ADD OwnerSplitCity Nvarchar(255)

UPDATE [dbo].[Nashville_Housing_data]
SET OwnerSplitCity = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2)

ALTER TABLE [dbo].[Nashville_Housing_data]
ADD OwnerSplitState Nvarchar(255)

UPDATE [dbo].[Nashville_Housing_data]
SET OwnerSplitState = PARSENAME(REPLACE([OwnerAddress], ',', '.') ,1)

SELECT *
FROM [dbo].[Nashville_Housing_data]

--Replacing 'Y' and 'N' with 'YES' and 'NO' in SoldAsVacant column using the CASE statement
SELECT DISTINCT [SoldAsVacant]
FROM [dbo].[Nashville_Housing_data]

SELECT DISTINCT [SoldAsVacant], COUNT([SoldAsVacant])
FROM [dbo].[Nashville_Housing_data]
GROUP BY [SoldAsVacant]
ORDER BY 2

SELECT [SoldAsVacant],
       CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
	        WHEN [SoldAsVacant] = 'N' THEN 'No'
			ELSE [SoldAsVacant]
	 END
FROM [dbo].[Nashville_Housing_data]

--Updating the soldasvacant column to main yes and no
UPDATE [dbo].[Nashville_Housing_data]
SET [SoldAsVacant] = CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
	                      WHEN [SoldAsVacant] = 'N' THEN 'No'
			              ELSE [SoldAsVacant]
	                 END

--Removing duplicates
--Using windows function ROW_NUMBER
SELECT *,
   ROW_NUMBER() OVER (PARTITION BY [ParcelID], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]
                      ORDER BY [UniqueID ] ) AS Row_num
FROM [dbo].[Nashville_Housing_data]
ORDER BY [ParcelID]

--Creating a CTE
WITH RowNum_CTE AS (
SELECT *,
   ROW_NUMBER() OVER (PARTITION BY [ParcelID], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]
                      ORDER BY [UniqueID ] ) AS Row_num
FROM [dbo].[Nashville_Housing_data])

SELECT *
FROM RowNum_CTE
--WHERE Row_num > 1
--ORDER BY [PropertyAddress]

--So deleting off the duplicate rows using the where clause result in the CTE 
WITH RowNum_CTE AS (
SELECT *,
   ROW_NUMBER() OVER (PARTITION BY [ParcelID], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]
                      ORDER BY [UniqueID ] ) AS Row_num
FROM [dbo].[Nashville_Housing_data])

DELETE
FROM RowNum_CTE
WHERE Row_num > 1

--Deleting unused columns
SELECT *
FROM [dbo].[Nashville_Housing_data]

ALTER TABLE [dbo].[Nashville_Housing_data]
DROP COLUMN [OwnerAddress], [TaxDistrict], [PropertyAddress], [SaleDate]
