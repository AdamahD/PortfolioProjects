select *
from dbo.[Nashville Housing Data for Data Cleaning]

--CLEANING DATA IN SQL QUERIES

--STANDARDIZE DATE FORMAT

Select SaleDateconverted, convert(Date, SaleDate)
from dbo.[Nashville Housing Data for Data Cleaning]

Update [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add SaleDateConverted Date

Update [Nashville Housing Data for Data Cleaning]
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data
Select *
from [Nashville Housing Data for Data Cleaning]
where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing Data for Data Cleaning] a
join [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing Data for Data Cleaning] a
join [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null




-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from [Nashville Housing Data for Data Cleaning]
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from [Nashville Housing Data for Data Cleaning]


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress nvarchar(255)

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitCity nvarchar(255)

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select *

from [Nashville Housing Data for Data Cleaning]



select OwnerAddress
from [Nashville Housing Data for Data Cleaning]


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from [Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select *
from [Nashville Housing Data for Data Cleaning]




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from [Nashville Housing Data for Data Cleaning]


--REMOVE DUPLICATES



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
from [Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress

SELECT *
FROM [Nashville Housing Data for Data Cleaning]

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
FROM [Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

