/*

Cleaning Data in SQL Quaries

*/

Select * 
From Portfolio_Project..NashvilleHousing

------------------------------------------------
--- Standardize Date Format

-- Change Date format to normal
Select SaleDate, CONVERT(Date,Saledate)
From Portfolio_Project..NashvilleHousing

-- Update format into column
Update NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate)


-- Another way to do it
ALTER Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

Select SaleDateConverted
From Portfolio_Project..NashvilleHousing

------------------------------------------------

--- Populate Property Address data

-- Looking for the most data
Select PropertyAddress
From Portfolio_Project..NashvilleHousing
Where PropertyAddress is null

-- Looking for the data
Select *
From Portfolio_Project..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID	-- Data will have duplicate ParcelID and we will use the first one and its not null


-- Find the data that will cause problem
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project..NashvilleHousing a
Join Portfolio_Project..NashvilleHousing b
	On a.ParcelID = b.ParcelID				-- To generate and see what is the same then use them
	and a.[UniqueID ] <> b.[UniqueID ]		-- reference with UniqueID for make sure that is not the same
Where a.PropertyAddress is null


-- Update data into null rows and run above query again, if it null, then it works!
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)		-- Replace the null value into data that we have and it is the same parcelID
From Portfolio_Project..NashvilleHousing a
Join Portfolio_Project..NashvilleHousing b
	On a.ParcelID = b.ParcelID				-- To generate and see what is the same then use them
	and a.[UniqueID ] <> b.[UniqueID ]	
Where a.PropertyAddress is null

------------------------------------------------

--- Breaking out address into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio_Project..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address						-- Break address from PropertyAddress and remove comma ','
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as AddressCity	-- Break City
From Portfolio_Project..NashvilleHousing


-- Create Column for new data Address and City
ALTER Table Portfolio_Project..NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER Table Portfolio_Project..NashvilleHousing
add PropertySplitCity nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Call the asset

Select *
From Portfolio_Project..NashvilleHousing

----------------------------
-- Owner asset --

Select OwnerAddress
From Portfolio_Project..NashvilleHousing



Select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
From Portfolio_Project..NashvilleHousing


ALTER Table Portfolio_Project..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER Table Portfolio_Project..NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER Table Portfolio_Project..NashvilleHousing
add OwnerSplitState nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

-- Call the asset

Select *
From Portfolio_Project..NashvilleHousing

------------------------------------
-- Change Y and N to Yes and No  in "Sold as Vacant" field

Select distinct (SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_Project..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
From Portfolio_Project..NashvilleHousing
--where SoldAsVacant = 'N'

Update Portfolio_Project..NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- Call the asset
Select *
From Portfolio_Project..NashvilleHousing


-------------------------------------------------
-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelID,
				propertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num
From Portfolio_Project..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------
-- Delete Unused columns

Select *
From Portfolio_Project..NashvilleHousing

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP column SaleDate

---------------------------------------
