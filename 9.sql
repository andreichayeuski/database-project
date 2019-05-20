USE Arenda;
select * from Contracts
--1
-- ����� �����
SELECT Cars.Marka_car, SUM(Contracts.Cost_arenda) OVER(PARTITION BY Car ORDER BY Car ASC) AS �mount, Date_arenda_end FROM Contracts
JOIN Cars ON Cars.Id_car = Contracts.Car
WHERE Contracts.Date_arenda_end BETWEEN '2019-02-02' AND '2019-04-01';

-- ��������� � ����� ������� ������� (� %);
WITH Aggregates AS
(
    SELECT Car, SUM(Cost_arenda) AS sumval
    FROM Contracts
    GROUP BY Car
)
SELECT distinct O.Car, Cost_arenda,
    CAST(100. * Cost_arenda / A.sumval AS NUMERIC(5, 2)) AS pctcust
FROM Contracts AS O
    JOIN Aggregates AS A ON O.Car = A.Car
WHERE Date_arenda_end BETWEEN '2019-02-02' AND '2019-04-01';



SELECT Car, Cost_arenda
    ,SUM(Cost_arenda) OVER(PARTITION BY Car) AS Total  
    ,CAST(1. * Cost_arenda / SUM(Cost_arenda) OVER(PARTITION BY Car)   
        *100 AS DECIMAL(5,2)) AS "Percent by Car"  
FROM Contracts   
WHERE Contracts.Date_arenda_end BETWEEN '2019-02-02' AND '2019-04-01';


WITH Aggregates AS
(
    SELECT Car, SUM(Cost_arenda) AS sumval
    FROM Contracts
    GROUP BY Car
)
SELECT distinct O.Car, 
    CAST(100. * A.sumval / sum(A.sumval) AS NUMERIC(5, 2)) AS pctcust
FROM Contracts AS O
    JOIN Aggregates AS A ON O.Car = A.Car 
WHERE Date_arenda_end BETWEEN '2019-02-02' AND '2019-04-01' and A.sumval > 0
group by o.car



 SELECT Car, SUM(Cost_arenda) OVER(PARTITION BY Car) AS sumval
	,CAST(100. * Cost_arenda / sum(Cost_arenda) OVER(PARTITION BY Car) AS NUMERIC(5, 2)) AS pctcust
    ,CAST(1. * Cost_arenda / MAX(Cost_arenda) OVER(PARTITION BY Car)   
        *100 AS DECIMAL(5,2)) AS "Percent by Car"  
    FROM Contracts
    GROUP BY Car


-- ��������� � �������� ���������� ������ ������� (� %).
SELECT Car, Cost_arenda  
    ,SUM(Cost_arenda) OVER(PARTITION BY Car) AS Total  
    ,CAST(1. * Cost_arenda / MAX(Cost_arenda) OVER(PARTITION BY Car)   
        *100 AS DECIMAL(5,2)) AS "Percent by Car"  
FROM Contracts   
WHERE Contracts.Date_arenda_end BETWEEN '2019-02-02' AND '2019-04-01';


--3.��������� ����������� ������� �� ��������.
--ROW_NUMBER ��������� ���������� �������������� � ������, ������� � 1 � � ����� 1
SELECT * , ROW_NUMBER() OVER(PARTITION BY Car ORDER BY Car) AS rownum
FROM Contracts;


--4. ROW_NUMBER() ��� �������� ���������� (� partition ���� ��� ���� �����������)
SELECT count(*) FROM Contracts;

delete x from (
  select *, rn=row_number() over (partition by Car, Date_arenda_start, Date_arenda_end, Client, Cost_arenda  order by Car)
  from Contracts 
) x
where rn > 1;

--5 ������� ��� ������� ���� �������� ����� �� ������ ��������� 6 ������� ���������.
select 
	Marka_car,
	Status_car,
	Date_arenda_end,
	sum(Cost_arenda) over (partition by Status_car, month(Date_arenda_end) order by Date_arenda_end) as [count],
	rn	=row_number() over (partition by Status_car, month(Date_arenda_end) order by Date_arenda_end)
	from Cars join Contracts on Cars.Id_car = Contracts.Car
where Month(Contracts.Date_arenda_end) between month(GETDATE()) - 6 and month(GETDATE())

select * from Clients
select * from Cars
--6 ����� ������ ���� ������������� ���������� ����� ��� ��� ������������� ����? ������� ��� ���� ��������.
select Clients.Name_client, Contracts.Car from Clients
join Contracts on Contracts.Client = Clients.Id_client

SELECT Cars.status_car, Cars.Marka_car, Contracts.Client,
  Count(Cost_arenda),
  RANK() OVER(partition by Contracts.Client, status_car ORDER BY Count(Cost_arenda) DESC) AS rnk
FROM Contracts
  JOIN Cars ON Cars.Id_car = Contracts.Car
GROUP BY status_car, Marka_car, Contracts.Client;




--���������� ������� 2 ������� � ����� �������
declare @sumval int;
set @sumval =(select sum(Cost_arenda) from Contracts)

declare @maxval int;
set @maxval = (select top(1) sum(Cost_arenda) suma from Contracts group by Car order by suma desc)
SELECT O.Car,
    CAST(100. * sum(o.Cost_arenda) /  @sumval AS NUMERIC(5, 2)) AS pctcust,
	@sumval, 
	sum(o.Cost_arenda),
	CAST(100. * sum(o.Cost_arenda) / @maxval AS NUMERIC(5, 2)) AS pctmax,
	@maxval
FROM Contracts AS O
group by o.Car


-- ���������� ������� 5 �������
select 
	Status_car,
	month(Date_arenda_end),
	sum(Cost_arenda),
	rn	=row_number() over (partition by month(Date_arenda_end) order by month(Date_arenda_end))
	from Cars join Contracts on Cars.Id_car = Contracts.Car
where Month(Contracts.Date_arenda_end) between month((select max(Date_arenda_end) from Contracts)) - 5 and month((select max(Date_arenda_end) from Contracts))
group by month(Date_arenda_end), Status_car