
---- I HAVE ADDED COMMENTS ABOUT LOGIC/STEPS I FOLLOWED TO CLEAN THE DATA--=

--OBJECTIVE -  TO CONVERT DIRTY DATA INTO MORE USABLE FORMAT.

-- TASKS IN BRIEF :
-- Identified duplicates in Data to drop it later.
-- Populated data into empty fields.
-- Made data consistent.
-- Changed Date into more usable format.
-- Seperated Strings and inserted new columns where I stored the seperated strings


------ Coverted the 'Saledate' column into date type and dropped the time entry.------------

SELECT Saledateconverted FROM CovidPortfolio.dbo.Nashville

SELECT Saledate, CONVERT(Date,Saledate)  FROM CovidPortfolio.dbo.Nashville

UPDATE Nashville
SET Saledate = CONVERT(Date,Saledate)
FROM CovidPortfolio.dbo.Nashville

ALTER TABLE Nashville
Add Saledateconverted Date;

UPDATE Nashville
SET Saledateconverted = CONVERT(Date,Saledate)
FROM CovidPortfolio.dbo.Nashville

-------------- Populating data into the Null Property Address columns-------------


-- Here I have found out (by studying data) that having same parcelid means address is same
-- hence created a self join and joined them on ParcelID which is common between them
-- and to have unique entries in both the tables, joined them on a.UniqueID <> b.UniqueID



-- Checked the join here
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM CovidPortfolio.dbo.Nashville a JOIN CovidPortfolio.dbo.Nashville b
ON a.ParcelID =b.ParcelID AND a.UniqueID <> b.UniqueID


-- Checking if my query is populating the Null using ISNULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CovidPortfolio.dbo.Nashville a JOIN CovidPortfolio.dbo.Nashville b
ON a.ParcelID =b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


-- Updated the column using UPDATE and my query using ISNULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CovidPortfolio.dbo.Nashville a JOIN CovidPortfolio.dbo.Nashville b
ON a.ParcelID =b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL





----   Splitting Strings in PropertyAddress   ----


-- Now I have inserted a seperate column for address and city by splitting 
-- the Property address into two columns using Substring



SELECT PropertyAddress FROM Nashville


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) 
FROM Nashville


ALTER TABLE Nashville
Add PropertySlpitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySlpitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)
FROM CovidPortfolio.dbo.Nashville

ALTER TABLE Nashville
Add PropertySlpitCity Nvarchar(255);

UPDATE Nashville
SET PropertySlpitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) 
FROM CovidPortfolio.dbo.Nashville

-- Will drop the original property address later



-- Splitting Owner address using PARSENAME as I have ',' delimeter, I can replace ',' with 
-- a '.' as PARSENAME works only when there's a fullstop/period/dot is present


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
 FROM Nashville


 ---  Creating columns and updating using the query which I have built earlier


 ALTER TABLE Nashville
Add OwnerSlpitCity Nvarchar(255);

ALTER TABLE Nashville
Add OwnerSlpitAddress Nvarchar(255);

ALTER TABLE Nashville
Add OwnerSlpitState Nvarchar(255);

UPDATE Nashville
SET OwnerSlpitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
FROM CovidPortfolio.dbo.Nashville

UPDATE Nashville
SET OwnerSlpitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
FROM CovidPortfolio.dbo.Nashville

UPDATE Nashville
SET OwnerSlpitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM CovidPortfolio.dbo.Nashville



-- Next task is to check Y and N values and replace them because we need uniform data

SELECT SoldAsVacant, Count(SoldAsVacant) FROM Nashville GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'N' then 'No'
	WHEN SoldAsVacant = 'Y' then 'Yes'
	ELSE SoldAsVacant
	END
FROM CovidPortfolio.dbo.Nashville


UPDATE Nashville
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'N' then 'No'
	WHEN SoldAsVacant = 'Y' then 'Yes'
	ELSE SoldAsVacant
	END
FROM CovidPortfolio.dbo.Nashville


----------------         Dealing with Duplicates      ---------------------


-- Check DUPLICATES first, I have used ROW_NUMBER() to auto number the duplicate entries
-- Partition by should include columns where a repeat entry would mean as a duplicate.
-- Used CTE to use the temp autonumbered table.
-- Later one can choose to delete the entries if required.


WITH DUPLICATES as (

SELECT 
ROW_NUMBER() OVER (Partition by ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
, SoldAsVacant Order by UniqueId) as Row_num

FROM Nashville
)
SELECT Row_num FROM DUPLICATES WHERE Row_num > 1