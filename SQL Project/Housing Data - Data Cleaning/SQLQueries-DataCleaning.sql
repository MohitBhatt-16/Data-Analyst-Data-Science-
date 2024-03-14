Select * From HousingData


-----------------------------------------------------------------------------------------------------------------------------


----Standardize Sale Date Format


Select SaleDate, CONVERT(Date,SaleDate) 
From HousingData

Update HousingData
Set SaleDate = Convert(Date,SaleDate)

Alter Table HousingData
Add SaleDateConverted Date

Update HousingData
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted 
From HousingData


-------------------------------------------------------------------------------------------------------------------------


---Populate Property Address Data


Select PropertyAddress 
From HousingData

Select * 
From HousingData
Where PropertyAddress is null

Select a.UniqueID,a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID != b.UniqueID
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID != b.UniqueID
Where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------


---- Breaking address into Address, City, State


--Property Address
Select PropertyAddress
From HousingData

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
SubString(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,Len(PropertyAddress)) As City
From HousingData

Alter Table HousingData
Add PropertySplitAddress nvarchar(255)

Update HousingData
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table HousingData
Add PropertySplitCity nvarchar(255)

Update HousingData
Set PropertySplitCity  = SubString(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,Len(PropertyAddress))

Select PropertySplitAddress,PropertySplitCity from HousingData


--Owner Address

Select OwnerAddress From HousingData

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From HousingData

Alter Table HousingData
Add OwnerSplitAddress nvarchar(255)

Update HousingData
Set OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 

Alter Table HousingData
Add OwnerSplitCity nvarchar(255)

Update HousingData
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table HousingData
Add OwnerSplitState nvarchar(255)

Update HousingData
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select  OwnerSplitAddress, OwnerSplitCity, OwnerSplitState From HousingData


---------------------------------------------------------------------------------------------------------------------------


-----Change Y and N to yes and no in sold and vacant


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From HousingData
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
From HousingData


Update HousingData
Set SoldAsVacant = CASE
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END


--------------------------------------------------------------------------------------------------



----Removing columns


Alter Table HousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Select * from HousingData
