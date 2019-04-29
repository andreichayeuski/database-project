use Arenda
go

select * from Report
--TASK1
create table Report (
id INTEGER primary key identity(1,1),
xml_column XML
);

--TASK2	
alter procedure generateXML
as
declare @x XML
set @x = (Select Name_client [Имя_водителя], 
Marka_car [Номер_автомобиля], GETDATE() [Дата]  
from Contracts contracte join Cars trnumber on contracte.Id_contract = trnumber.Id_car
join Clients client on client.Id_client = trnumber.Id_car
FOR XML AUTO);
SELECT @x
go

execute generateXML;

--TASK3
create procedure InsertInReport
as
DECLARE  @s XML  
SET @s = (Select Name_client [Имя_водителя], 
Marka_car [Номер_автомобиля], GETDATE() [Дата]  
from Contracts contracte join Cars trnumber on contracte.Id_contract = trnumber.Id_car
join Clients client on client.Id_client = trnumber.Id_car
for xml raw);
--FOR XML AUTO, TYPE);
insert into Report values(@s);
go
  
  execute InsertInReport
  select * from Report;

--task4
create primary xml index My_XML_Index on Report(xml_column)

create xml index Second_XML_Index on Report(xml_column)
using xml index My_XML_Index for path

--task5
select * from Report

alter procedure SelectData
as
select xml_column.query('/row') as[xml_column] from Report for xml auto, type;
go

execute SelectData
