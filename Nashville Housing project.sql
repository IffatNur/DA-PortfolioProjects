--Nisheville housing

select *
from PortfolioProject..NashvilleHousing

--standardize date format

update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate);

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);

select SaleDateConverted, SaleDate, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing;


--populate property address data

select *
from PortfolioProject..NashvilleHousing

select a.ParcelID, a.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress), b.ParcelID,b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out property address into indivisual column (address, city, state)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as Address,
	substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as State
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1);

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select * 
from PortfolioProject..NashvilleHousing

--breaking out owner's address into indivisual column (address, city, state)

select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME( REPLACE( OwnerAddress,',','.'), 3),
PARSENAME( REPLACE( OwnerAddress,',','.'), 2),
PARSENAME( REPLACE( OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255); 

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255); 

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255); 

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE( OwnerAddress , ',','.'), 3)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',','.'),1)

--change soldvacant Y and N to Yes and No

select distinct SoldAsVacant, COUNT(SoldAsVacant) as total
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by total

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = 
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end


--remove duplicate rows

with RowNumCTE as(
select *, 
	ROW_NUMBER() over(
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice
					 order by UniqueID
					 )row_num
from PortfolioProject..NashvilleHousing
)
select * 
from RowNumCTE 
where row_num > 1
order by PropertyAddress

--delete unused column

select * 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict