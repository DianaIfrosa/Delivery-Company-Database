


--delivery_prices
INSERT INTO delivery_prices VALUES(1, 20, 'Romania');
INSERT INTO delivery_prices VALUES(2, 50, 'Europe UE');
INSERT INTO delivery_prices VALUES(3, 350, 'SUA');
INSERT INTO delivery_prices VALUES(4, 150, 'Europe non-UE');
INSERT INTO delivery_prices VALUES(5, 500, 'others');

--bonus
INSERT INTO bonus VALUES(1,5,100);
INSERT INTO bonus VALUES(2,10,200);
INSERT INTO bonus VALUES(3,15,300);
INSERT INTO bonus VALUES(4,20,450);
INSERT INTO bonus VALUES(5,30,600);

--weight_codes
INSERT INTO weight_codes VALUES(1,0,3,0);
INSERT INTO weight_codes VALUES(2,3,5,5);
INSERT INTO weight_codes VALUES(3,5,10,10);
INSERT INTO weight_codes VALUES(4,10,20,30);
INSERT INTO weight_codes VALUES(5,30,50,40);

--addresses
INSERT INTO addresses VALUES (1,'Strada Florilor, nr.10, bl.45, sc.A', 1907, 'Bucuresti', 'Romania');
INSERT INTO addresses VALUES (2,'Strada Bucovinei, bl.175, sc.A', 1345, 'Iasi', 'Romania');
INSERT INTO addresses VALUES (3,'Rue Saint-Denis, 6A', 0342, 'Paris', 'France');
INSERT INTO addresses VALUES (4,'Gifford Street, no.10, 60B', 2124, 'London', 'UK');
INSERT INTO addresses VALUES (5,'Washington Avenue no.7',8332, 'Chicago', 'Illinois');
INSERT INTO addresses VALUES (6,'Baihe Rd 50', 90067, 'Beijing', 'China');
INSERT INTO addresses VALUES (7,'Bissell Street no. 2',8532, 'Birmingham', 'UK');
INSERT INTO addresses VALUES (8,'Stanton Street no.7', 93267, 'Detroit', 'Michigan');

--customers
INSERT INTO customers VALUES (1,'+40789691739', 'juridical', null, null);
INSERT INTO customers VALUES (2,'+4050381049', 'natural', 'BCR 1111 2222 3333 444', 'anad@gmail.com');
INSERT INTO customers VALUES (3,'+44904810381' , 'natural', null, 'georh@gmail.com');
INSERT INTO customers VALUES (4,'+40728401830', 'juridical', null, 'anamariat@yahoo.com');
INSERT INTO customers VALUES (5,'+14844578786', 'natural', 'BRD 0921 9402 2839 8382', null);
INSERT INTO customers VALUES (6,'+18143519576', 'natural', null, null);
INSERT INTO customers VALUES (7,'+40730184020', 'juridical', 'BCR 5920 5820 4829 4422', null);
INSERT INTO customers VALUES (8,'+40638193812', 'juridical', 'ING 7982 1222 4850 2840', 'alexyr01@gmail.com');
INSERT INTO customers VALUES (9,'+40631093444', 'juridical', 'BRD 8509 9999 6748 2829', 'floreap79@yahoo.com');
INSERT INTO customers VALUES (10,'+17142219576', 'natural', 'BT 8904 4729 2233 0094 0089', null);

--cars
INSERT INTO cars VALUES(1,'Mercedes', 2013, to_date('20-03-2018'));
INSERT INTO cars VALUES(2,'Dacia', 2017, to_date('13-08-2019'));
INSERT INTO cars VALUES(3,'BMW', 2016, to_date('12-06-2019'));
INSERT INTO cars VALUES(4,'Opel', 2019, to_date('03-04-2020'));
INSERT INTO cars VALUES(5,'Dacia', 2020, to_date('15-08-2021'));
INSERT INTO cars VALUES(6,'BMW', 2017, to_date('07-01-2021'));

--customers_juridical_persons
INSERT INTO customers_juridical_persons VALUES(1,'SC ARC SRL','ro904803','Ross Ege');
INSERT INTO customers_juridical_persons VALUES(4,'SC Rotaria SRL','ro285019','Ana Maria Tica');
INSERT INTO customers_juridical_persons VALUES(7,'SC WISDOM SRL','ro904810','Oliver Smith');
INSERT INTO customers_juridical_persons VALUES(8,'SC Doni SRL' ,'ro912422','Alex Ristei');
INSERT INTO customers_juridical_persons VALUES(9,'SC FloriP SRL','ro123422','Florea Patricia');

--customers_natural_persons
INSERT INTO customers_natural_persons VALUES(2,'Ana Maria', 'Dinu');
INSERT INTO customers_natural_persons VALUES(3,'George','Horea');
INSERT INTO customers_natural_persons VALUES(5,'Ellis','Green');
INSERT INTO customers_natural_persons VALUES(6,'Dragos','Dinu');
INSERT INTO customers_natural_persons VALUES(10,'Taylor', 'Deen');

--couriers
INSERT INTO couriers VALUES(1, 'Razvan', 'Manea','+40572911192', 4, to_date('05-01-2015'), 2300, 1, to_date('01-01-2015'));
INSERT INTO couriers VALUES(2, 'Florina', 'Robu', '+40768401233', 2, to_date('04-10-2015'), 2500, 2, to_date('02-10-2015'));
INSERT INTO couriers VALUES(3, 'Darius', 'Enescu', '+40796940277', 1, to_date('10-09-2019'), 2000, 3, to_date('04-09-2019'));
INSERT INTO couriers VALUES(4, 'Oana', 'Alexandrescu', '+40757391822', 3, to_date('01-03-2017'), 1800, 3, to_date('28-02-2017'));
INSERT INTO couriers VALUES(5, 'Francisc', 'Olaru', '+40799098954', 6, to_date('25-04-2021'), 2500, null, to_date('21-04-2021'));

--shipments
INSERT INTO shipments VALUES (1, to_date('18-06-2019'), 1, 200);
INSERT INTO shipments VALUES (2, to_date('10-11-2020'), 2, 700);
INSERT INTO shipments VALUES (3, to_date('10-12-2021'), 3, 1500);
INSERT INTO shipments VALUES (4, to_date('05-01-2022'), 4, 1300);
INSERT INTO shipments VALUES (5, to_date('23-06-2019'), 1, 100);

--orders
INSERT  INTO orders VALUES (1,1, to_date('10-04-2019'),'card fizic', 350, 1, 'Ilie Elena', 1, 1, 1);
INSERT  INTO orders VALUES (2,2, to_date('11-05-2019'), 'card online', 200, 5, 'SC HM SRL', 2, 1, 1);
INSERT  INTO orders VALUES (3,3, to_date('13-06-2019'), 'cash', 300, 4, 'SC ZARA SRL', 2, 2, 1);
INSERT  INTO orders VALUES (4,4, to_date('23-05-2020'), 'cash', 250, 2, 'Rotaru Florin', 3, 3, 2);
INSERT  INTO orders VALUES (5,5, to_date('02-11-2020'), 'card online', 580, 5, 'SC DANUBIS SRL', 4, 4, 4);
INSERT  INTO orders VALUES (6,6, to_date('05-12-2021'), 'card fizic', 500, 8, 'SC ERDA SRL', 3, 5, 3);
INSERT  INTO orders VALUES (7,7, to_date('19-08-2021'), 'card online', 1740, 4, 'Manolache Tina', 4, 6, 5);
INSERT  INTO orders VALUES (8,8, to_date('21-09-2021'), 'cash', 1630, 6, 'Eva Popescu', 5, 6, 5);
INSERT  INTO orders VALUES (9,9, to_date('30-11-2021'), 'card online', 180, 5, 'SC GARDEN SRL', 2, 7, 4);
INSERT  INTO orders VALUES (10,10, to_date('10-12-2021'), 'card fizic', 250, 2, 'SC DEDEMAN SRL', 1, 8, 3);

--shipments_contain_orders
INSERT INTO shipments_contain_orders VALUES(1, 1, 'failed', 1, 350, null);
INSERT INTO shipments_contain_orders VALUES(1, 2, 'success', 2, 100, 'nice courier');
INSERT INTO shipments_contain_orders VALUES(1, 3, 'success', 3, 170, null);
INSERT INTO shipments_contain_orders VALUES(2, 4, 'success', 2, 250, 'late delivery');
INSERT INTO shipments_contain_orders VALUES(2, 5, 'failed', 5, 580, null);
INSERT INTO shipments_contain_orders VALUES(3, 6, 'success', 8, 500, null);
INSERT INTO shipments_contain_orders VALUES(4, 7, 'success', 4, 1740, 'damaged packaging');
INSERT INTO shipments_contain_orders VALUES(4, 8, 'success', 6, 1630, null);
INSERT INTO shipments_contain_orders VALUES(5, 3, 'success', 1, 130, 'fast delivery');
INSERT INTO shipments_contain_orders VALUES(5, 2, 'failed', 3, 100, null);

--accidents_history
INSERT INTO accidents_history VALUES(1, 1, 1, to_date('04-06-2015'), 400);
INSERT INTO accidents_history VALUES(2, 2, 1, to_date('15-09-2017'), 500);
INSERT INTO accidents_history VALUES(3, 3, 2, to_date('30-09-2019'), 700);
INSERT INTO accidents_history VALUES(4, 2, 2, to_date('14-08-2020'), 1300 );
INSERT INTO accidents_history VALUES(5, 5, 6, to_date('21-08-2021'), 200);

--cars history
INSERT INTO cars_history VALUES(1, to_date('01-01-2015'), to_date('01-10-2015'), 1);
INSERT INTO cars_history VALUES(1, to_date('02-10-2015'), to_date('20-03-2019'), 3);
INSERT INTO cars_history VALUES(2, to_date('02-10-2015'), to_date('07-07-2020'), 1);
INSERT INTO cars_history VALUES(3, to_date('02-09-2019'), to_date('02-10-2020'), 2);
INSERT INTO cars_history VALUES(4, to_date('18-02-2017'), to_date('27-12-2021'), 5);
COMMIT;