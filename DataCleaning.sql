select * from
dbo.NashvilleHousing;

--Data Cleaning
select SaleDate , convert(Date,SaleDate)
from dbo.NashvilleHousing;

Update  NashVilleHousing
SET SaleDate = convert(Date,SaleDate);
--update wont change data type 
Alter Table NashvilleHousing Alter Column SaleDate Date;

--Populate property add

select * from
dbo.NashvilleHousing
where PropertyAddress is NULL;

select a.ParcelID,b.PropertyAddress,a.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing as a
JOIN dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing as a
JOIN dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL;


select * from
dbo.NashvilleHousing;

----Breaking address into state city

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
FROM dbo.NashvilleHousing;

Alter table  dbo.NashvilleHousing
ADD street varchar(255);

Update a
SET street = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
from dbo.NashvilleHousing a;

Alter table  dbo.NashvilleHousing
ADD city varchar(255);

Update a
SET city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from dbo.NashvilleHousing a;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing;

/*ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing
*/

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS TransformedSoldAsVacant
FROM
    dbo.NashvilleHousing;

	UPDATE NashvilleHousing
	set 
    SoldAsVacant=
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END 
FROM
    dbo.NashvilleHousing;

	select distinct(SoldAsVacant),count(SoldAsVacant)
	from NashvilleHousing
	group by SoldAsVacant
	order by 2;

	
-- Delete Unused Columns



Select *
From dbo.NashvilleHousing;


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
