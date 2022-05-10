/*
Cleaning Data in SQL Queries.
*/

SELECT  *
FROM    NashvilleHousing;
---------------------------------------------------------------------------

-- Standardize Data Format

SELECT  SaleDate, CONVERT(DATE, SaleDate)
FROM    NashvilleHousing;

UPDATE  NashvilleHousing 
SET     SaleDate = CONVERT(DATE, SaleDate);

SELECT  SaleDate
FROM    NashvilleHousing;
----------------------------------------------------------------------------

-- Populate Property Address Data

SELECT  PropertyAddress
FROM    NashvilleHousing
WHERE   PropertyAddress IS NULL;

SELECT      *
FROM        NashvilleHousing
ORDER BY    ParcelID; 


SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
        ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM    NashvilleHousing a JOIN NashvilleHousing b
        ON  a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE   a.PropertyAddress IS NULL;


UPDATE  a
SET     PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM    NashvilleHousing a JOIN NashvilleHousing b
        ON  a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE   a.PropertyAddress IS NULL;

----------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT  PropertyAddress
FROM    NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
FROM    NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE  NashvilleHousing
SET     PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE  NashvilleHousing
SET     PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- USE PARSENAME
SELECT  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM    NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD         OwnerSplitAddress NVARCHAR(255);

UPDATE  NashvilleHousing
SET     OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD         OwnerSplitCity NVARCHAR(255);

UPDATE  NashvilleHousing
SET     OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD         OwnerSplitState NVARCHAR(255);

UPDATE  NashvilleHousing
SET     OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM    NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE  NashvilleHousing
SET     SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                            WHEN SoldAsVacant = 'N' THEN 'No'
                            ELSE SoldAsVacant
                            END
FROM    NashvilleHousing;

----------------------------------------------------------------------------------

-- Remove Duplicates
-- USE CTE

WITH RowNumCTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice,
                                                SaleDate, LegalReference
                                ORDER BY UniqueID) row_num
    FROM    NashvilleHousing
)
DELETE  
FROM    RowNumCTE
WHERE   row_num > 1

----------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict; 