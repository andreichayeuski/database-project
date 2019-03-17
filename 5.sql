use Arenda
drop table Clients;
drop table Cars;
drop table Contracts;
drop table DTP

create table Clients(
Id_client int IDENTITY(1,1) primary key,
Name_client nvarchar(50),
Passport_client nvarchar(50),
Experience_year_client int,
Telephone_client nvarchar(10),
Address_client nvarchar(50)
)

create table Cars(
Id_car int IDENTITY(1,1) primary key,
Marka_car nvarchar(50),
Color_car nvarchar(50),
Status_car nvarchar(50)
)

create table Contracts(
Id_contract int IDENTITY(1,1) primary key,
Date_arenda_start date,
Date_arenda_end date,
Client int,
Car int,
Cost_arenda int,
Year_arenda_start as year(Date_arenda_start),
FOREIGN KEY (Client) REFERENCES Clients(Id_client) ON DELETE CASCADE,
FOREIGN KEY (Car) REFERENCES Cars(Id_car) ON DELETE CASCADE
)

alter table Contracts add  Year_arenda_start as year(Date_arenda_start)

create table DTP(
hid hierarchyid NOT NULL,--иеарарх. столбец
Id_dtp int IDENTITY(1,1) not null,
Date_dtp date,
Id_contract int,
Procent_broken int,
About_dtp varchar(50),
CHECK (Procent_broken between 1 and 100),
FOREIGN KEY (Id_contract) REFERENCES Contracts(Id_contract) ON DELETE CASCADE,
CONSTRAINT PK_Table_1 PRIMARY KEY CLUSTERED 
(
  [hid] ASC
))



insert into Clients values('Petya','RR12345678',3,'147-12-92','Ymanskaya 19');
insert into Clients values('Alla','RR12345687',1 ,'159-29-49','Katachatova 12');
insert into Clients values('Anastasya','RR1234567',2,'147-87-74','Azbekova 8');
insert into Clients values('Nikolay','RR1475236',5 ,'156-23-34','Armena 121');
insert into Clients values('Vasiliy','RR87654321',6 ,'785-63-98','Aleva 23');

select * from Clients;

Insert into Cars values('Toyota RAV4','Blue','New');
Insert into Cars values('Toyota Camry','White','Old');
Insert into Cars values('Fiat Punto','Black','Old, crashed');
Insert into Cars values('Honda Civic','Orange','old');
Insert into Cars values('Kia Rio','Black','New');

select * from Cars;

Insert into Contracts values('17-02-2019','25-02-2019', 5,5 ,300);
Insert into Contracts values('17-03-2018','25-03-2018', 5,4 ,120);
Insert into Contracts values('11-02-2019','21-02-2019', 3,2 ,145);
Insert into Contracts values('01-02-2019','07-02-2019', 2,1 ,230);
Insert into Contracts values('03-02-2019','13-02-2019', 2,5 ,500);
Insert into Contracts values('18-02-2019','20-02-2019', 3,3 ,300);
Insert into Contracts values('21-02-2019','24-02-2019', 2,3 ,250);
Insert into Contracts values('25-02-2019','28-02-2019', 3,3 ,100);
Insert into Contracts values('16-02-2019','17-02-2019', 2,2 ,200);

select * from Contracts;

Insert into DTP values(hierarchyid::GetRoot(),'20-02-2019',6,10,'Pozarapal krylo');
--Insert into DTP values(hierarchyid::GetRoot(),'24-02-2019',6,20,'Pozarapal vtoroe krylo');

--Insert into DTP values(hierarchyid::GetRoot(),'17-02-2019',9,10,'Pozarapala krylo');
--Insert into DTP values(hierarchyid::GetRoot(),'28-02-2019',9,95,'Razbila');

select * from DTP;
------------------
delete from DTP

declare @Id hierarchyid

select @Id = MAX(hid)
from DTP
where hid.GetAncestor(1) = hierarchyid::GetRoot() --выбирает все записи, предком (прямым) которых является корень;

insert into DTP
values(hierarchyid::GetRoot().GetDescendant(@id, null),'24-02-2019',6,20,'Pozarapal vtoroe krylo');-- выбирает первый свободный hierarchyid прямых потомков корня дерева

select @Id = MAX(hid)
from DTP
where hid.GetAncestor(1) = hierarchyid::GetRoot() 

insert into DTP
values(hierarchyid::GetRoot().GetDescendant(@id, null),'25-02-2019',6,20,'Pozarapal pervoe krylo');

-------
declare @phId hierarchyid
select @phId = (SELECT hid FROM DTP WHERE Id_dtp = 19);

select @Id = MAX(hid)
from DTP
where hid.GetAncestor(1) = @phId

insert into DTP
values( @phId.GetDescendant(@id, null),'26-02-2019',6,20,'Zarapina #1');
--
select @phId = (SELECT hid FROM DTP WHERE Id_dtp = 20);

select @Id = MAX(hid)
from DTP
where hid.GetAncestor(1) = @phId

insert into DTP
values( @phId.GetDescendant(@id, null), '26-02-2019',6,20,'Zarapina #1-1');
------------------------

select hid.ToString(), hid.GetLevel(), * from DTP

---------------------------
drop procedure PodchinYzel

GO  
CREATE PROCEDURE PodchinYzel(@level int)    
AS   
BEGIN  
   select hid.ToString(), * from DTP where hid.GetLevel() = @level;
END;  
GO  

exec PodchinYzel 2;
---------------------------------

GO  
CREATE PROCEDURE AddDocherYzel(@Id_dtp int,@date_dtp date,@id_contract int,@procent_broken int, @About_dtp nvarchar(50))  -- для добавления дочернего узла
AS   
BEGIN  
declare @Id hierarchyid
declare @phId hierarchyid
select @phId = (SELECT hid FROM DTP WHERE Id_dtp = @Id_dtp);

select @Id = MAX(hid)
from DTP
where hid.GetAncestor(1) = @phId

insert into DTP
values( @phId.GetDescendant(@id, null),@date_dtp,@id_contract,@procent_broken,@About_dtp);
END;  
GO  
----------------------------

exec AddDocherYzel 21,'15-03-2019',6,30,'Zarapina #2'

----------

go
CREATE PROCEDURE MoveYzel(@old_dtp int, @new_dtp int )
AS  
BEGIN  
DECLARE @nold hierarchyid, @nnew hierarchyid  
SELECT @nold = hid FROM DTP WHERE Id_dtp = @old_dtp ;  
  
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE  
BEGIN TRANSACTION  
SELECT @nnew = hid FROM DTP WHERE Id_dtp = @new_dtp ;  
  
SELECT @nnew = @nnew.GetDescendant(max(hid), NULL)   
FROM DTP WHERE hid.GetAncestor(1)=@nnew ;  
  
UPDATE DTP    
SET hid = hid.GetReparentedValue(@nold, @nnew)  
WHERE hid.IsDescendantOf(@nold) = 1 ;  
  
  END ;  
GO  
----
exec MoveYzel 23,20
select hid.ToString(), hid.GetLevel(), * from DTP