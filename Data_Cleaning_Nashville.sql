/*

Cleaing Data in SQL

*/

Select *
From PortfolioProject..NashvilleHousing

-- Standardize/Change Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

-- I want to remove the extra zeros at the end of the date

Alter Table PortfolioProject..NashvilleHousing
Alter Column SaleDate Date

------ Populate Property Address data for null values ------

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID /*notice that Identical ParcelId's have the same PropertyAddress*/

-- self join to find where the parcelid is the same, but one of the PropertyAddress is null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] /*same Parcelid but unique row*/
Where a.PropertyAddress is null

-- now updating to populate null addresses
update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- checking for null values now returns nothing
Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null



----- Breaking out Address into Individual Columns (Address, City, State) ---------

Select PropertyAddress
From PortfolioProject..NashvilleHousing


-- Commas in Address

--counting from 1st character until a comma, and then going back one so the comma isn't included
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
-- FIND comma, start one AFTER that then print the rest
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing 

-- We separated one Column into two values, So we need new columns for them

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- check if it worked, (adds new columns to the end)
Select *
From PortfolioProject..NashvilleHousing

-- Working on Owner Address (separating like above)
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
-- Parsename looks for a period by default, if we change all of our commas to periods with REPLACE, we'll get what we need)
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

-- Creating new columns and updating them
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
From PortfolioProject..NashvilleHousing



--- CHANGE Y and N to Yes and No in "Sold as Vacant" ---

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

-- changing with a case statement
Select SoldAsVacant,
Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

-- updating column
update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



----- Removing Duplicates ----

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) as row_num
From PortfolioProject..NashvilleHousing
)

--DELETE
SELECT *
From RowNumCTE
Where row_num > 1





------- Delete Unused Columns -----

-- DON'T DELETE STUFF FROM REAL RAW DATA


Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress