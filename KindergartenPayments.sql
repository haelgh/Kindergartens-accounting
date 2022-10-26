create database kindergartenpayments;
use kindergartenpayments;

create table kindergarten(
	id int primary key not null auto_increment,
    name_ varchar(10) unique
)engine = InnoDB;

create table department(
	id int primary key not null auto_increment,
    name_ varchar(15)
)engine = InnoDB;

create table parent(
	id int primary key not null auto_increment,
    name_ varchar(30) unique not null,
    departmentID int,
    accountNum int not null unique, 
    foreign key (departmentID) references department(id)
    on update cascade
    on delete set null
)engine = InnoDB;

create table kid(
	id int primary key not null auto_increment,
	accountNum int,
    bill int not null,
    name_ varchar(30),
    kindergartenNum int,
    foreign key (kindergartenNum) references kindergarten(id),
    foreign key (accountNum) references parent(accountNum)
    on update cascade
    on delete set null
)engine = InnoDB;

create table siblings(
	id int primary key not null auto_increment,
	accountNum int,
    bill int not null,
    name_ varchar(30),
    kindergartenNum int,
    foreign key (kindergartenNum) references kid(id),
    foreign key (accountNum) references parent(accountNum)
    on update cascade
    on delete set null
)engine = InnoDB;

create table payment(
	accountNum int,
    child int,
    amountMonth int, 
    foreign key (child) references kid(id),
    foreign key (accountNum) references kid(accountNum)
    on update cascade
    on delete set null
)engine = InnoDB;

insert into kindergarten(name_) values ('Sun'), ('Flower'), ('Butterfly'), ('Bird');
select*from kindergarten;

insert into department(name_) values ("Law"), ("Management"), ("IT"), ("Science"), ("Education");
select*from department;

insert into department(name_) values ("Medicine"), ("Engineering"), ("Art");
select*from department;

insert into parent(name_, departmentID, accountNum) values 
('Smith', '1', '1236'),
('Willow', '2', '2345'), 
('Lit', '3', '3456'), 
('Ribb', '4', '4567'),
('Willson', '5', '5678'), 
('Summoner', '1', '6789'), 
('Stark', '2', '7891'), 
('Joy', '3', '8912'); 
select*from parent;

insert into kid(accountNum, bill, name_ , kindergartenNum) values 
('1236', '156', 'Rick', '1'), 
('2345', '654', 'Sam', '2'), 
('3456', '312','Jill', '3'),
('4567', '456', 'Mark', '4'), 
('5678', '600', 'Sia', '1'), 
('6789', '398', 'Mile', '2'), 
('7891', '220', 'John', '3'), 
('8912', '550', 'Mira', '4'),
('6789', '398', 'Kate', '2'), 
('7891', '220', 'Jerry', '3'), 
('8912', '550', 'Lee', '4');
select*from kid;

insert into siblings(accountNum, bill, name_ , kindergartenNum) values  
('6789', '398', 'Mile', '2'), 
('7891', '220', 'John', '3'), 
('8912', '550', 'Mira', '4'),
('6789', '398', 'Kate', '2'), 
('7891', '220', 'Jerry', '3'), 
('8912', '550', 'Lee', '4');
select*from siblings;

insert into payment(accountNum, child, amountMonth) values 
('3456','1', '3'),
('4567','2', '5'), 
('5678', '3', '7'), 
('6789', '4', '4'), 
('7891', '5', '2'), 
('8912','6', '6'),
('2345','7', '8'), 
('2345','8', '8'), 
('1236', '9', '1'), 
('2345','10', '8'),
('2345','11', '8');
select*from payment;

select distinct kid.name_, kid.accountNum
from kid
where not exists (
	select * from parent where kid.accountNum=parent.accountNum
); 

DELIMITER &&  
CREATE PROCEDURE get_merit_kids()  
BEGIN  
    SELECT * FROM kid WHERE kindergartenNum = 3;  
END &&  
DELIMITER ;  
call get_merit_kids() ;


DELIMITER &&  
CREATE PROCEDURE get_family(in accNum int)  
BEGIN  
    SELECT kid.*, parent.name_ as surname, parent.departmentID FROM kid, parent WHERE kid.accountNum = accNum and parent.accountNum = accNum;  
END &&  
DELIMITER ;  
call get_family(6789) ;

DELIMITER &&  
CREATE PROCEDURE get_course(in amtMon int)  
BEGIN  
    SELECT distinct * FROM payment WHERE payment.amountMonth = amtMon;  
END &&  
DELIMITER ;  
call get_course(8) ;

DELIMITER &&  
CREATE PROCEDURE display_biggest_bill (OUT biggestBill INT)  
BEGIN  
    SELECT accountNum, name_, MAX(bill) FROM kid;   
END &&  
DELIMITER ;  
call display_biggest_bill(@B);

DELIMITER $$
CREATE FUNCTION KindergartenLevel(
	id int
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE kindergartenLevel VARCHAR(20);
    IF id=3 THEN
		SET kindergartenLevel = 'Private';
    ELSEIF id=4 THEN
        SET kindergartenLevel = 'Biligual';
    ELSEIF id=2 THEN
        SET kindergartenLevel = 'Technical';
	ELSEIF id=1 THEN
        SET kindergartenLevel = 'Special Needs';
    END IF;
	RETURN (kindergartenLevel);
END$$
DELIMITER ;

SELECT name_, kindergartenLevel(id) FROM
    kindergarten
ORDER BY 
    name_;


DELIMITER $$
CREATE FUNCTION urgentPayments(
	bill double
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE urgency varchar(20);
    IF bill<200 THEN
		SET urgency = 'Normal';
    ELSEIF bill>200 and bill<500 THEN
        SET urgency = 'Partial';
    ELSEIF bill>500 THEN
        SET urgency = 'Full';
    END IF;
	RETURN (urgency);
END$$
DELIMITER ;

SELECT accountNum,  urgentPayments(bill) FROM 
    kid
ORDER BY 
    accountNum;


