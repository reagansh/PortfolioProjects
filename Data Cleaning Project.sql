-----Data Cleaning

Select *
From PortfolioProject.dbo.NashvilleHousing

----Standardize Date Formate

select saledate1
From [dbo].[NashvilleHousing]

select saledate, CONVERT(Date, SaleDate)
From NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing    -------Issues with thisn method
set SaleDate = CONVERT(Date, SaleDate)

Alter TAble PortfolioProject.dbo.NashvilleHousing ----------altanetive approach
add SaleDate1 Date

update PortfolioProject.dbo.NashvilleHousing
set SaleDate1 = CONVERT(Date, SaleDate)



----------------------------------------------------------------------------------------------
---Population of Property Address data

select propertyaddress
from PortfolioProject.dbo.NashvilleHousing
order by Propertyaddress

select *
from PortfolioProject.dbo.NashvilleHousing
where Propertyaddress is null
order by ParcelID, propertyaddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  where a.PropertyAddress is null

  Update a 

  set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  where a.PropertyAddress is null


 ------Breakup Address into Column (Address, City, State)

 select propertyaddress
from PortfolioProject.dbo.NashvilleHousing
order by Propertyaddress

select 
SUBSTRING(propertyAddress, 1, Charindex(',', PropertyAddress)) as Address
, SUBSTRING (propertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousing

Alter TAble PortfolioProject.dbo.NashvilleHousing 
add PropertyAddress1 Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertyAddress1 = SUBSTRING(propertyAddress, 1, Charindex(',', PropertyAddress) -1 ) 

Alter TAble PortfolioProject.dbo.NashvilleHousing 
add PropertyAddress2 Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertyAddress2 = SUBSTRING (propertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


----------Spliting Table Using Delimited Seperator

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
From PortfolioProject.dbo.NashvilleHousing

Alter TAble PortfolioProject.dbo.NashvilleHousing 
add OwnerAddress1 Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter TAble PortfolioProject.dbo.NashvilleHousing 
add OwnerCity Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter TAble PortfolioProject.dbo.NashvilleHousing 
add OwnerState Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




---------Case Statement-----------------------

select distinct(soldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant


select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


-----------REMOVING DUPLICATES
With RowNumCTE AS(
select*,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate1,
				LegalReference
				Order By
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
select *
from RowNumCTE
where row_num > 1

---Delete
---from RowNumCTE
---where row_num > 1


--------------------------Delete Unsued Columns----------------------------

Alter TAble PortfolioProject.dbo.NashvilleHousing 
drop Column OwnerAddress, TaxDistrict, PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing

Alter TAble PortfolioProject.dbo.NashvilleHousing 
drop Column SaleDate