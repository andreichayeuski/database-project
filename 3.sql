use Arenda;
exec sp_configure 'clr_enabled', 1
exec sp_configure 'clr_strict_security', 0
reconfigure

create assembly GetCount
	from 'D:\���������\�����������\6 �������\���������������� � ������������ ��� ������ Web-���������� - 3 ����\3lab\3lab\bin\Debug\3lab.dll'
	with permission_set = safe;

go
create procedure GetCount (@dateStart datetime, @dateEnd datetime)
	as external name GetCount.StoredProcedures.GetCount

declare @ref int
exec @ref = GetCount '01-01-2018', '01-02-2019'
print @ref

select * from Clients
pivot (
  count(Experience_year_client) for Id_client in ([1], [2], [3])
) as pvt