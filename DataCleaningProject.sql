/*

Data Cleaning Project In SQL

*/
SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate Date

--------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
SELECT nhse.ParcelID, nhse.PropertyAddress, nhou.ParcelID, nhou.PropertyAddress, ISNULL(nhse.PropertyAddress, nhou.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nhse
JOIN PortfolioProject..NashvilleHousing nhou
	ON nhse.ParcelID = nhou.ParcelID
	AND nhse.[UniqueID ] != nhou.[UniqueID ]
WHERE nhse.PropertyAddress is NULL

UPDATE nhse
SET PropertyAddress = ISNULL(nhse.PropertyAddress, nhou.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nhse
JOIN PortfolioProject..NashvilleHousing nhou
	ON nhse.ParcelID = nhou.ParcelID
	AND nhse.[UniqueID ] != nhou.[UniqueID ]
WHERE nhse.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------------------
-- Spliiting up the Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(188);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(188);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(188);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------------------------------------
-- Changing the Y and N values to 'Yes' and 'No' in the SoldAsVacant column
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num

From PortfolioProject.dbo.NashvilleHousing)

DELETE
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress






