use [Home Data Cleaning]

select * from Sheet1$
order by [UniqueID ];

--Change date to a standard format
select SaleDate from Sheet1$;
Select SaleDate, Convert(Date, SaleDate) as SalesDateUpdated 
from Sheet1$;

Alter table Sheet1$
add ConvertedSalesDate Date;

Update Sheet1$ 
set ConvertedSalesDate = CONVERT(Date, SaleDate)


Alter table Sheet1$
drop column SaleDate;

Select ConvertedSalesDate from Sheet1$;
Select * from Sheet1$;


--Populate property Address Data
select PropertyAddress 
from Sheet1$
where PropertyAddress is NULL;

--We have some rows where Property Address field is empty. What I have done is that, I have joined the table with itself and checked using ParcelID field
--that if two parcel IDs are same and one of them doesn't have property address populated then populate it with the others address.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PopulatedPropertyAddress
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

select * from Sheet1$;

--Split address in three different columns that is Address, city and state.
select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)) as Address
from Sheet1$;
--The above query shows the comma as well in result. To remove comma we have used the below given query.
select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
from Sheet1$;

alter table Sheet1$
drop column Address, State;

Alter table Sheet1$
add Address nvarchar(225),
State nvarchar(225);

Update Sheet1$
Set Address = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) from Sheet1$;

Update Sheet1$
Set State = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress));

Select * from Sheet1$;


--Owner Address Splitting Using parsname

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from Sheet1$;

Alter table Sheet1$
add OwnerAddressNew nvarchar(255),
OwnerState nvarchar(255),
OwnerCountry nvarchar(255);

Update Sheet1$
set OwnerAddressNew = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update Sheet1$
set OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Update Sheet1$
set OwnerCountry = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

select * from Sheet1$;


--Change SoldAsVacant Column

select distinct(SoldAsVacant), COUNT(SoldAsVacant) from Sheet1$
group by SoldAsVacant;

select SoldAsVacant
, Case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
from Sheet1$

Update Sheet1$
set SoldAsVacant = Case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

Select SoldAsVacant, count(SoldAsVacant) from Sheet1$ group by SoldAsVacant;


--Remove duplicates

Select * from Sheet1$;

With rowNumCTE As(
Select *,
		ROW_NUMBER() Over(
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 ConvertedSalesDate,
					 LegalReference
					 Order by
						UniqueID
						) row_num

from Sheet1$
)

delete from rowNumCTE where row_num > 1;

Select * from Sheet1$;

--Delete Extra columns which are not necessary

Alter table Sheet1$
drop column Acreage, TaxDistrict, HalfBath;

select * from Sheet1$;