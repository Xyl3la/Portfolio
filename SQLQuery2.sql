-- Data Cleaning

select *
from PortfolioProject..Nashville_Housing;


-- Standardizing the date

select SaleDate, convert(date,SaleDate)
from PortfolioProject..Nashville_Housing

update PortfolioProject..Nashville_Housing
set SaleDate = CONVERT(Date,SaleDate)

alter table Nashville_Housing
Add SaleDateConverted Date;

--Update Nashville_Housing
--Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
from PortfolioProject..Nashville_Housing;

-- Populated address data using self join as there are similirities in ParcelID 

select *
from PortfolioProject..Nashville_Housing
--where PropertyAddress is null
order by ParcelID
	
select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Nashville_Housing a
join PortfolioProject..Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress	is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Nashville_Housing a
join PortfolioProject..Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

-- Breaking the address into indivisual columnns

select PropertyAddress
from PortfolioProject..Nashville_Housing
--where PropertyAddress is null
--order by ParcelID


-- splitting wrt to 
select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

from PortfolioProject..Nashville_Housing

alter table PortfolioProject..Nashville_Housing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..Nashville_Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)

alter table PortfolioProject..Nashville_Housing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..Nashville_Housing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select
* from PortfolioProject..Nashville_Housing

-- Owner Address trying different things(since parse name works in reverse we use 3,2,1

select 
parsename (Replace(OwnerAddress,',','.'),3),
parsename (Replace(OwnerAddress,',','.'),2),
parsename (Replace(OwnerAddress,',','.'),1)
from PortfolioProject..Nashville_Housing

alter table PortfolioProject..Nashville_Housing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..Nashville_Housing
set OwnerSplitAddress = parsename (Replace(OwnerAddress,',','.'),3)

alter table PortfolioProject..Nashville_Housing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..Nashville_Housing
set OwnerSplitCity = parsename (Replace(OwnerAddress,',','.'),2)

alter table PortfolioProject..Nashville_Housing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..Nashville_Housing
set OwnerSplitState = parsename (Replace(OwnerAddress,',','.'),1)

Select
* from PortfolioProject..Nashville_Housing


-- Chaning the column sold as vacant(using case statement)

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..Nashville_Housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..Nashville_Housing

update PortfolioProject..Nashville_Housing
set SoldAsVacant =case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- Removing Duplicates

With RowNumCTE as(
select *,
         row_number() over(
         partition by ParcelID,
		              PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					  Order by UniqueID
					  ) row_num

from PortfolioProject..Nashville_Housing
--order by ParcelID
)

delete  
from RowNumCTE	
where row_num>1

-- Deleting unused columns

Select* 
from PortfolioProject..Nashville_Housing

alter table PortfolioProject..Nashville_Housing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProject..Nashville_Housing
drop column SaleDate