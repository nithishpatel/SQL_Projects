select * from
/*Adding filter 2*/
(select *,
		case when Filter_1='Check' then case when Collection_Rate<0.45 and Net_Balance-Balance_Card<100 then 'Yes' else 'No' end else ' ' end as Filter_2 from
/*Adding filter 1*/
(select *,
		case when (NINV_Changed_Final>NINV and Monitoring_Status='XCAN') or (Liquid_Check='Liquid')then 'Keep' else 'Check' end as Filter_1 from
/*Adding column Liquid Check*/
(select *,
		case when Installation_Number='226849' or Installation_Number='237699' or Installation_Number='248120' or  Installation_Number='2483467' or Installation_Number='263337' or  Installation_Number='297378' then 'Liquid' else ' ' end as Liquid_Check from
(select z.*,Cut_Service_Report.Monitoring_Status,Cut_Service_Report.Contract_Status from
(select y.*,Collection_Fee.Ctr_No from
(select * from
/*Adding column Filter*/
(select *,
		case when Collection_Rate<0.45 and (Net_Balance-Balance_Card)<100 then 'Yes' else 'No' end as Filter from
/*Adding columns Overpaid by card, Invoice_group and Payment group*/
(select * ,
        case when Taken_By_Us-Net_Balance>0 then Taken_By_Us-Net_Balance else 0 end as Overpaid_By_Card,
        case when NINV=1 then '1' when NINV=2 then '2' when NINV=3 then '3' when NINV=4 then '4' when NINV=5 then '5' when NINV>=6 then '6 or more' end as Invoice_Group,
        case when Formula_2='Paid' then 'Full Paid' else 'Partial Paid' end as Payment_Group  from 
(select Table_5.*, Card_Payment_CRM.Amount,Card_Payments as Taken_By_Us from


/*Adding column formula 2*/
(select *,
        case when Balance_Card<6 then 'Paid' when Formula='Payment Plan' then 'Payment Plan' when Formula='Paid' then 'Paid' when (Card_Payments>=Net_Balance/nullif(NINV,0)) then 'Payment Plan' when Card_Payments>=50 then 'Payment Plan' else 'UnPaid' end as Formula_2 from
/*Adding columns collection rate,collected_amount,Formula*/
(select *,
        case when (Net_Balance-Balance_Card/Net_Balance)<0 then 0 else (Net_Balance-Balance_Card)/Net_Balance end as Collection_Rate,
        case when (Net_Balance-Balance_Card)<0 then 0 else Net_Balance-Balance_Card end as Collected_Amount,
        case when Updated_Balance <6 then 'Paid' when (Net_Balance - Updated_Balance)>=(Net_Balance/ nullif(NINV,0)) then 'Payment Plan' when (Net_Balance - Updated_Balance)>=50 then 'Payment Plan' else 'UnPaid' end as Formula  from
(select *,
        case when Card_Payments>=Card_Allocation then case when (Updated_Balance-Card_Payments+Card_Allocation)>0 then Updated_Balance-Card_Payments+Card_Allocation else 0 end else Updated_Balance end as Balance_Card from
(select Table_1.*,Table_2.Updated_Balance,Table_3.Amount as Card_Payments,Table_4.sum_importe as Card_Allocation from
(select * from Aging_Monthly_Installations) Table_1
left join
/*Updated balance starts*/
(select Installation_Number, sum(Net_Balance) as Updated_Balance from
(select *,
        case when Filter_1='OT' and (External_Invoice_Number like '%MTP%'or External_Invoice_Number like '%MTN%') then 'O' else Filter_1 end as Filter_2 from
(select *,
        case when Invoice_Charge_Date<Todays_Date then 'Yes' else 'No' end as Filter,
        case when Invoice_Type='O' and External_Invoice_Number not like '%C%' and Invoice_Charge_Date>='2022-08-01' and Importe='999999' then 'OT' else Invoice_Type end as Filter_1 from
(select *,CAST(CURRENT_TIMESTAMP AS DATE) Todays_Date from Collections.Aging_Raw_1st_Month_Data) a)b)c
where filter='Yes' and Filter_2<>'OT'
group by Installation_Number,Net_Balance) Table_2
/*Updated balance ends*/
on Table_2.Installation_Number=Table_1.Installation_Number
left join
/* Card Payment starts*/
/* Easy Pay Complete starts*/
(Select Installation_Number, SUM(Amount) as Amount from
(select Contract_Number as Installation_Number,Channel as Status,sum(Amount_paid) as Amount from Collections.Easy_Pay_Data_Daily
where Channel='CARD'
group by Contract_Number,Channel
/* Easy Pay Complete ends*/
UNION ALL
/* Uni Pay Complete starts*/
Select Customer_ID as Installation_Number, Transaction_Status as Status, SUM(Amount/Count_1) as Amount from
(Select Customer_ID, Transaction_Status, Count(Order_ID) as Count_1, SUM(Amount) as Amount from
(Select *, CONCAT(Customer_ID,'-', Order_ID) as Customer_Order_ID from Collections.UNI_Pay_Data_Daily
where Transaction_status= 'CAPTURED') a
GROUP BY Customer_ID, Transaction_Status) b
GROUP BY Customer_ID, Transaction_Status) Uni_EasyPay
where Installation_Number IS NOT NULL
GROUP BY Installation_Number) Table_3
on Table_1.Installation_Number=Table_3.Installation_Number
/* Uni Pay Complete ends*/
/* Card Payment ends*/
left join
/*Payment received starts*/
(select Numero_de_Instalacion,sum(Importe) as sum_importe from Collections.Payments_Received_Data_Daily
where Dsc_Tipo_Transaccion='CARD' or Dsc_Tipo_Transaccion like '%EASYPAY%'
group by Numero_de_Instalacion,Importe) Table_4
on Table_1.Installation_Number=Table_4.Numero_de_Instalacion)a)b)c) Table_5
/*Payment received ends*/
left join
/*Card_Payment_CRM starts*/
(select Installation_Number,sum(Amount) as Amount  from
(select Contract_Number as Installation_Number,Channel as Status,sum(Amount_paid) as Amount from
(select *,
        case when Todays_Date<=Date then 'Yes' else 'No' end as Filter from
(select Contract_Number,Channel,Date,Amount_paid,CAST(CURRENT_TIMESTAMP AS DATE) Todays_Date  from Collections.Easy_Pay_Data_Daily)a)b
where Filter='Yes' and Channel='CARD'
Group by Contract_Number,Channel,Amount_paid

UNION ALL

select Customer_ID as Installation_Number,Channel as Status,sum(Amount) as Amount from
(select *,
        case when Auth_DateTime>=Todays_Date then 'Yes' else 'No' end as Filter from
(select Customer_ID,Channel,Auth_DateTime,Transaction_status,Amount,CAST(CURRENT_TIMESTAMP-1 AS DATE) Todays_Date from Collections.UNI_Pay_Data_Daily)a)b
where Filter='Yes' and Transaction_status='CAPTURED'
Group by Customer_ID,Channel,Amount)c
group by Installation_Number) Card_Payment_CRM
/*Card_Payment_CRM ends*/
on Table_5.Installation_Number=Card_Payment_CRM.Installation_Number) CRM_Balance_Amount
where not exists
/*CRM_Balance_Importe starts*/
(select * from
(select CUSTOMER_ID,INV_STAT,sum(AMO) as Amount from Collections.CRM_Balance_Data_Daily
where INV_STAT='PENDING'
Group by CUSTOMER_ID,INV_STAT,AMO)a
where CRM_Balance_Amount.Installation_Number=a.CUSTOMER_ID))s
where NINV_Changed_Final>=5)x
where Filter='Yes')y
/*CRM_Balance_Importe ends*/
left join 
/* joining collection_fee*/
(select * from
(select Ctr_No,count(Ctr_No) as Count_Ctr_Number from Collections.Collection_Fee_Daily_Data
where To_Date='31/12/2999'
group by Ctr_No)c
where Ctr_No=NULL)Collection_Fee 
on y.Installation_Number=Collection_Fee.Ctr_No) z
left join
(select Installation_Number,Monitoring_Status,Contract_Status from Collections.Customer_Info_Daily_Data) Cut_Service_Report
on z.Installation_Number=Cut_Service_Report.Installation_Number)r)o
where NINV_Changed_Final>5 or Liquid_Check='Liquid')q)r
where Filter_2='Yes' or Filter_2=' '
