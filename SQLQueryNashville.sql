/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [ProjectPortfolio].[dbo].[NashvilleHousing]

--- Standardise date format

SELECT SaleDate,CONVERT(Date, SaleDate) FROM ProjectPortfolio.dbo.NashvilleHousing 

Update ProjectPortfolio.dbo.NashvilleHousing
SET SaleDate=CONVERT(Date, SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update ProjectPortfolio.dbo.NashvilleHousing
SET SaleDateConverted=CONVERT(Date, SaleDate)

SELECT SaleDateConverted,CONVERT(Date, SaleDate) FROM ProjectPortfolio.dbo.NashvilleHousing 

--------------------------
------ Populate Property address data

SELECT * FROM ProjectPortfolio.dbo.NashvilleHousing
where PropertyAddress is NULL

--we noticed that where the ParcelID is the same for two or more properties then their addresses in also the same in most cases

Select *
From ProjectPortfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From ProjectPortfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update ProjectPortfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update ProjectPortfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From ProjectPortfolio.dbo.NashvilleHousing





Select OwnerAddress
From ProjectPortfolio.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From ProjectPortfolio.dbo.NashvilleHousing



ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From ProjectPortfolio.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from ProjectPortfolio.dbo.NashvilleHousing
Group by SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectPortfolio.dbo.NashvilleHousing


Update ProjectPortfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

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
					) row_num
From ProjectPortfolio.dbo.NashvilleHousing
)

Select *
From RowNumCTE
where row_num > 1

DELETE
From RowNumCTE
where row_num > 1






Select *
From ProjectPortfolio.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate