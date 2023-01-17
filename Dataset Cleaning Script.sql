/*

Cleaning Data in SQL Queries

PORTFOLIO TASKS

*/
 select * from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
-------------------------------------------------------------------------------------------

-- Standardize Date Format

 select Saledate from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

  select Saledate, CONVERT(Date, Saledate) from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

  /*
  UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
  SET SaleDate = CONVERT(Date, SaleDate)

  This query did not produce diesried result, hence the alter table and update queries were used below
 */
   select * from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

   ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
   ADD SaleDateConverted Date

   Update NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
   SET SaleDateConverted = CONVERT(Date, SaleDate)


------------------------------------------

-- Populate Property Address data

Select * from 
NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing 
--where PropertyAddress is null 
order by ParcelID

Select tab1.ParcelID, tab1.PropertyAddress, 
tab2.ParcelID, tab2.PropertyAddress,
ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing tab1
 JOIN NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing tab2
 ON tab1.ParcelID = tab2.ParcelID
 AND tab1.[UniqueID ] <> tab2.[UniqueID ]
WHERE tab1.PropertyAddress is null


UPDATE tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing tab1
 JOIN NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing tab2
 ON tab1.ParcelID = tab2.ParcelID
 AND tab1.[UniqueID ] <> tab2.[UniqueID ]
 where tab1.PropertyAddress is null

 SELECT * FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

----------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS ADDRESS
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS ADDRESS
FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

/*
The first substring separated the aaddress before the comma 
without including the comma in the new column using the "-1" function
The second substring used the charindex function to stipulate 
where the function should start counting from, then bring out the remaining words 
after the comma, using the +1 functionality
*/

ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
Add PropertySplitAddress Nvarchar(255);

UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
Add PropertySplitCity Nvarchar(255);

UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_Housing 
SET PropertySplitCity=  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing


/*
Moving on to owner address
we will seprater using PARSE NAME(used for stuff delimited by periods) function instead of substring just for the sake of trying something different
*/


SELECT OwnerAddress from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

/*
PARSENAME counts backwards, the last word  is the first and the first is the last. So counting must begin from the back
*/

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing


ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
Add OwnerSplitCity Nvarchar(255);

UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
Add OwnerSplitState Nvarchar(255);

UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

-------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field


SELECT Distinct(SoldAsVacant) from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'n' Then 'NO'
	ELSE SoldAsVacant
	END
from NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing


UPDATE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'n' Then 'NO'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT * FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing

WITH RowNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
--order by ParcelID
)
Select * from RowNumCTE
where row_num > 1
--Order by PropertyAddress
/*
Exchange select for delete to delete the duplicate data
*/

WITH RowNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
--order by ParcelID
)
Delete from RowNumCTE
where row_num > 1
--Order by PropertyAddress




-------------------------------------------------------------------------------
-- Delete Unused columns

SELECT * FROM 
NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing


ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


ALTER TABLE NASHVILLE_HOUSING_DATA_CLEANING_PROJECT.dbo.Nashville_housing
DROP COLUMN SaleDate



-----------------------------------------------------------------------------