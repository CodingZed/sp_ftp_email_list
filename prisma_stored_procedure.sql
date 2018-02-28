drop view zfang.prisma_base_all_v2
Create view prisma_base_all_v2 as 
Select isnull(replace(Advertiser_Name,'"',''),'Other') as Advertiser_Name, isnull(name.advertiser_code,'Other') as Advertiser_Code,
	   isnull(replace(placement_site,'"',''),'Other') as Placement_Site,isnull(name.product_name,'Other') as Product_Name,
	   isnull(name.product_code,'Other') as Product_Code,isnull(name.estimate_code,'Other') as Estimate_Code,
	   left(cast('1'+'-' + month as date),7) as Month,
	   isnull(name.placement_user,'Other') as Placement_User, round(isnull(sum(cast(planned_amount as float)),0),0) as Cost 
from [PrismaBulk].[DimPlacement] name 
left join [PrismaBulk].[PlacementMonthly] spend
on name.placement_id = spend.placement_id
where cast('1'+'-' + month as date)>='2017-07-01'
and (
advertiser_name like '%9/11%' or
advertiser_name like '%AARON%S%' or
--advertiser_name like '%AEG%Presents%' or
--advertiser_name like '%Atkins%' or
advertiser_name like '%Calvin%Klein%' or
advertiser_name like '%Dannon%' or
advertiser_name like '%Disney%' or
--advertiser_name like '%Dardens%'or
advertiser_name like '%Great Call%'or
advertiser_name like 'XX-INTEGRATED DNA T.'or
advertiser_name like '%Massage Envy%'or
advertiser_name like '%PFIZER CON%' or
advertiser_name like '%PROCTER & GAMBLE%'or
advertiser_name like '%PERFETTI VAN MELLE%'or
advertiser_name like '%Remax%'or
--advertiser_name like '%Elizabeth Arden Red Door Spa%'or
advertiser_name like '%Smuckers%'or

advertiser_name like '%Staples%'or
advertiser_name like '%Tommy Hilfiger%' or
advertiser_name like '%Home Depot%'or
advertiser_name like '%Fox%'or

advertiser_name like '%Adidas%' or
advertiser_name like '%BIDEAWEE%' or
advertiser_name like '%Diageo%'or
advertiser_name like '%Macy%s%' or
advertiser_name like '%Mondelez%' or
advertiser_name like '%Mastercard%' or

advertiser_name like '%Microsoft%' or
advertiser_name like '%Red%bull%' or
advertiser_name like '%Reebok%' or
advertiser_name like '%Shiseido%' or
advertiser_name like '%Sonos%' or
advertiser_name like '%Taylormade%' or

advertiser_name like '%Great%Call%' or
advertiser_name like '%Sonos%' or
advertiser_name like '%LongHorn%')
and (advertiser_code not like 'Q%' and 
advertiser_code not like 'X%' and 
advertiser_code not like 'Y%' and
advertiser_code not like 'Z%'  )
Group by Advertiser_Name, name.advertiser_code,placement_site,name.product_name,name.product_code,name.estimate_code,month,name.placement_user



drop table zfang.prisma_roll_all_v2
select * into zfang.prisma_roll_all_v2 from zfang.prisma_base_all_v2
delete from zfang.prisma_roll_all_v2


Alter table zfang.prisma_roll_all_v2
add input_date date not null 
default getdate()



drop procedure prisma_historical_append_all_v2
Create procedure prisma_historical_append_all_v2
AS
BEGIN 
     insert into zfang.prisma_roll_all_v2 (Advertiser_Name, Advertiser_Code,placement_site, product_name,product_code,estimate_code,
									Month, placement_user,Cost)
	  select Advertiser_Name, Advertiser_Code,placement_site, product_name,product_code,estimate_code,
									Month, placement_user,round(Cost,0) from 
	 (select base.Advertiser_Name, base.Advertiser_Code,base.placement_site, base.product_name,base.product_code,base.estimate_code,
			 base.Month, base.placement_user, base.Cost,roll.Advertiser_Name as Advertiser_Name2 from zfang.prisma_base_all_v2 base
	  left join 
	 (select * from zfang.prisma_roll_all_v2) roll
	 on base.Advertiser_Name = roll.Advertiser_Name and base.Advertiser_Code = roll.Advertiser_Code and 
	    base.placement_site = roll.placement_site and base.product_name = roll.product_name and 
	    base.product_code = roll.product_code and base.estimate_code = roll.estimate_code and
	    base.Month = roll.Month and base.placement_user = roll.placement_user and 
	    round(base.cost,0) = round(roll.cost,0)
	 where roll.Advertiser_Name is null) ttt   
END

prisma_historical_append_all_v2