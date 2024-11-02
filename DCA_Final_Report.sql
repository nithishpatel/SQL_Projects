/* DCA_final_report*/
select * from
(select Installation_Number,Contract_Status_Date,Contract_Status,Monitoring_Status,sum(Net_Balance) as Sum_Net_Balance from
(select *,
		case when Collection_Fee='Coll' then 'Ok' when Collection_Fee='Credit' then 'Check' when Collection_Fee='Cyc' then 'Check' else ' ' end as Final_Check from
(select *,
		case when Invoice_Amount=36 then case when Invoice_Amount=Previous_Amount then 'Credit'  else 'Coll' end else 'Cyc' end as Collection_Fee from Collections.DCA_Check_Daily_Data)a)b
where Group_1<>'CHKD' or Group_1<>'CLRREQ' or Group_1<>'CREDIT' or Group_1<>'DCA' or Group_1<>'WOFF' and Final_Check='Ok'
Group by Installation_Number,Contract_Status_Date,Contract_Status,Monitoring_Status,Net_Balance)a
where Sum_Net_Balance>139
