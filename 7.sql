use Arenda
go

select * from Report
--TASK1
create table Report (
id INTEGER primary key identity(1,1),
xml_column XML
);

--TASK2	
create procedure generateXML
as
declare @x XML
set @x = (Select Name_client [Имя клиента], 
Marka_car [Марка автомобиля], GETDATE() [Дата]  
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
SET @s = (Select Name_client [Имя клиента], 
Marka_car [Марка автомобиля], GETDATE() [Дата]  
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

create procedure SelectData
as
select xml_column.query('/row') as[xml_column] from Report for xml auto, type;
go

execute SelectData

select xml_column.value('(/row/@Дата)[1]', 'nvarchar(max)') as[xml_column] from Report for xml auto, type;

select r.Id,
	m.c.value('@Дата', 'nvarchar(max)') as [date]
from Report as r
	outer apply r.xml_column.nodes('/row') as m(c)

select xml_column.query('/row') as [xml_column] from Report for xml auto, type;
