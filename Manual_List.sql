/*Manual List Starts*/
select *,
		case when New_case_Group2=1 then 'GARY' when New_case_Group2=2 then 'FERENC' when New_case_Group2=3 then 'IWONA' when New_case_Group2=4 then 'MICHAEL' when New_case_Group3=1 then 'JODIE' when New_case_Group3=2 then 'MATHEW' when New_case_Group5=1 then 'RAMSEY' when New_case_Group5=2 then 'ANDREW' when New_case_Group5=3 then 'MARTIN' else Segment end as New_Cases_Assign from
(select *,
		case when Contracts_Group='Group_2' then (row_number() OVER (ORDER BY Contracts_Group)-1) % 4 + 1  end as New_case_Group2,
		case when Contracts_Group='Group_3' then (row_number() OVER (ORDER BY Contracts_Group)-1) % 2 + 1 end as New_case_Group3,
		case when Contracts_Group='Group_5' then (row_number() OVER (ORDER BY Contracts_Group)-1) % 3 + 1 end as New_case_Group5 from
(select *,
		case when Office='BO' then 'Keep' when Office='FO' and (Group1='5' or Contracts_Group='Group_5') then 'Keep' else 'Delete' end as Filter from
(select *,
		case when Contract_To_Assign='NEW' and NINV<=2 then 'Group_2' when Contract_To_Assign='NEW' and (NINV>2 and NINV<=4) then 'Group_3' when Contract_To_Assign='NEW' and NINV>4 then 'Group_5' else 'None' end as Contracts_Group from
(select *,
		case when Segment='NEW' then 'NEW' else ' ' end as Contract_To_Assign from
(select *,
		case when Group1='NEW' then 'NEW' when Group1='2' and (NINV=1 or NINV=2) then Previous_AGENT when Group1='3' and (NINV=3 or NINV=4) then Previous_AGENT when Group1='5' and (NINV>=5) then Previous_AGENT else 'NEW' end as Segment from
(select *,
		case when Previous_AGENT='NEW' then 'NEW' when Previous_AGENT='GARY' then '2' when Previous_AGENT='FERENC' then '2' when Previous_AGENT='IWONA' then '2' when Previous_AGENT='RAMSEY' then '5' when Previous_AGENT='ANDREW' then '5' when Previous_AGENT='MARTYN' then '5' when Previous_AGENT='MATHEW' then '3' when Previous_AGENT='JODIE' then '3' when Previous_AGENT='MICHAEL' then '2' else '-' end as Group1  from
(select Manual_list.*,contracts_crm.OFFICE,Previous_Agents.Agent, isNULL(Agent,'NEW') as Previous_Agent from
(select * from Aging_Monthly_Installations) Manual_list
left join
(select Distinct CUSTOMER,OFFICE,count(CUSTOMER) as Count_Customer from Collections.Contracts_CRM
Group by CUSTOMER,OFFICE)contracts_crm
on Manual_list.Installation_Number=contracts_crm.CUSTOMER
left join 
(select distinct CONTRACT,UPPER([AGENT NAME]) as Agent from Collections.Previous_Agents_list)Previous_Agents
on Previous_Agents.CONTRACT=Manual_list.Installation_Number)a)b)c)d)e)f
where Filter='Keep')g
order by Contracts_Group Asc,NINV desc, Net_Balance desc
/*Manual List ends*/
