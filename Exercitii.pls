
--Enunt ex6: Pentru fiecare tara in care s-a plasat o comanda, afisati numarul de comenzi plasate, numarul de orase in care au fost plasate acele comenzi 
--si numele oraselor. 

CREATE OR REPLACE PROCEDURE ex6 IS

TYPE t_countries IS TABLE OF addresses.country_name%TYPE INDEX BY PLS_INTEGER; --index-by-table
TYPE t_no_orders IS TABLE OF NUMBER INDEX BY PLS_INTEGER; --index-by-table
TYPE t_cities IS TABLE OF addresses.city_name%TYPE; --nested table
TYPE t_total_cities IS TABLE OF t_cities; --nested table

v_countries t_countries;
v_cities t_total_cities:=t_total_cities();
v_no_orders t_no_orders;

no_countries NUMBER;
no_cities NUMBER;

BEGIN

SELECT DISTINCT a.country_name, COUNT(*)
BULK COLLECT INTO v_countries, v_no_orders
FROM orders o JOIN addresses a ON o.destination_address_id=a.address_id
GROUP BY a.country_name
ORDER BY 1 DESC;

no_countries:=v_countries.COUNT;

FOR i IN 1..no_countries LOOP --for each country
    v_cities.EXTEND;
    
    SELECT DISTINCT a.city_name
    BULK COLLECT INTO v_cities(i)
    FROM orders o JOIN addresses a ON o.destination_address_id=a.address_id
    WHERE a.country_name=v_countries(i);
END LOOP;

DBMS_OUTPUT.PUT_LINE('Countries: ');

FOR i IN 1..no_countries LOOP --for each country
    DBMS_OUTPUT.PUT(v_countries(i) || ' has ' || v_no_orders(i));
    IF v_no_orders(i)=1 THEN
        DBMS_OUTPUT.PUT(' order in ');
    ELSE     
        DBMS_OUTPUT.PUT(' orders in ');
    END IF;
    
    DBMS_OUTPUT.PUT(v_cities(i).COUNT);
    IF v_cities(i).COUNT=1 THEN
        DBMS_OUTPUT.PUT(' city: ');
    ELSE     
        DBMS_OUTPUT.PUT(' cities: ');
    END IF;
    
    --print cities 
    no_cities:=v_cities(i).COUNT;
    FOR j IN 1..no_cities-1 LOOP
        DBMS_OUTPUT.PUT( v_cities(i)(j)|| ', ');
    END LOOP;
    DBMS_OUTPUT.PUT( v_cities(i)(no_cities)|| '.');
    
    DBMS_OUTPUT.NEW_LINE;    
END LOOP;

END;
/

BEGIN
    ex6();
END;
/

--Enunt ex7: Afisati curierii care au facut accident (id, nume, prenume), data acestuia, masina cu care s-a intamplat accidentul (id, brand si daca e cea curenta sau nu) si de cat timp era condusa de acel curier (aproximari corespunzatoare pentru zile, luni, ani). 

CREATE OR REPLACE PROCEDURE ex7 IS

CURSOR acc IS
           SELECT co.courier_id cour_id, co.first_name fn, co.last_name ln, ah.accident_date acc_date, cr.car_id car_id,
                  cr.brand brand, co.hire_date h_date, ch.date_start_usage start_date, co.date_start_usage_car start_date2
           FROM couriers co JOIN accidents_history ah ON co.courier_id=ah.courier_id
                 JOIN cars cr ON ah.car_id=cr.car_id
                 LEFT JOIN cars_history ch ON (ah.car_id=ch.car_id AND ah.courier_id=ch.courier_id
                                        AND ah.accident_date<=ch.date_end_usage AND ah.accident_date>=ch.date_start_usage )
            ORDER BY acc_date;        
period FLOAT;
is_current_car VARCHAR2(10);
unit_time VARCHAR2(10);

BEGIN
FOR i IN acc LOOP
    --decide if the car is the current one or an old one
    IF i.start_date IS NULL THEN
        period:=i.acc_date-i.start_date2; --current car
        is_current_car:='current ';
    ELSE
        period:=i.acc_date-i.start_date; --car driven in past
        is_current_car:='';
    END IF;
    --convert period to days, months or years
    IF period<=30 THEN
        unit_time:=' days';
    ELSIF period<=365 THEN
        unit_time:=' months';
        period:=ROUND(period/30);
    ELSE
        unit_time:=' years';
        period:=ROUND(period/365);
    END IF;
    DBMS_OUTPUT.PUT_LINE('Courier no. ' || i.cour_id || ' (' || i.fn || ' ' || i.ln || ') '
    || 'was involved in an accident on ' || i.acc_date || ' with ' || is_current_car ||  'car no. ' || i.car_id || ' (' || i.brand
    || ') ' || 'that he/she had been driving for almost ' || period || unit_time || '.' );
END LOOP;

END;
/

BEGIN
    ex7();
END;
/

--Enunt ex8: Afisati pentru un curier dat (id-ul lui) numarul de comenzi livrate (cu statusul "success"). Daca o comanda a fost sparta in mai multe pachete,
--trebuie ca toate pachetele sa fi fost livrate cu statusul "success". Afisati in plus si un mesaj daca acel curier nu are deloc comenzi inregistrate (indiferent
--daca sunt cu "succes" sau "failed").


CREATE OR REPLACE FUNCTION ex8(courier_id_given couriers.courier_id%TYPE) RETURN NUMBER IS

--for a given courier: find all orders delivered and the number of products deivered from those orders 
CURSOR c(c_id couriers.courier_id%TYPE) IS 
    SELECT o.order_id order_id, SUM(sco.no_products_delivered) no_products_delivered
    FROM orders o  JOIN shipments_contain_orders sco ON o.order_id=sco.order_id 
                   JOIN shipments s ON s.shipment_id=sco.shipment_id
    WHERE sco.status='success' AND s.courier_id=c_id
    GROUP BY o.order_id;
    
CURSOR total_shipments(c_id couriers.courier_id%TYPE) IS
    SELECT shipment_id
    FROM shipments
    WHERE courier_id=c_id;
    
no_orders NUMBER:=0;
no_products_total NUMBER;
c_exists NUMBER;
shipment_id_current shipments.shipment_id%TYPE;

not_existing_courier EXCEPTION;
not_existing_orders EXCEPTION;

BEGIN

--check if the courier_id exists
SELECT COUNT(*)
INTO c_exists
FROM couriers c_table
WHERE c_table.courier_id=courier_id_given;

IF c_exists=0 THEN 
    RAISE not_existing_courier;
END IF;

--check if the courier has any orders first
OPEN total_shipments(courier_id_given);
    LOOP
        FETCH total_shipments INTO shipment_id_current;  
        EXIT WHEN total_shipments%NOTFOUND;
    END LOOP;    
    
    IF total_shipments%rowcount=0 THEN
         CLOSE total_shipments;
         RAISE not_existing_orders;
    END IF;
    
CLOSE total_shipments;

FOR i IN c(courier_id_given) LOOP
    
    SELECT o.no_products_ordered
    INTO no_products_total
    FROM orders o 
    WHERE o.order_id=i.order_id;
    IF no_products_total=i.no_products_delivered THEN 
        no_orders:=no_orders+1;
    END IF;
END LOOP;

RETURN no_orders;

EXCEPTION
    WHEN not_existing_courier THEN
        RAISE_APPLICATION_ERROR(-20015,'There is no courier with the given id!');
     WHEN not_existing_orders THEN   
        DBMS_OUTPUT.PUT_LINE('The courier given has no orders at all!');
        RETURN 0;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Courier no. 1 delivered ' || ex8(50) || ' entire order(s).'); --error: There is no courier with the given id!
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Courier no. 1 delivered ' || ex8(1) || ' entire order(s).'); --Courier no. 1 delivered 1 entire order(s).
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Courier no. 5 delivered ' || ex8(5) || ' entire order(s).'); --The courier given has no orders at all!...
END;
/


--Enunt ex9: In contextul unei tombole a fost extras un nume la intamplare. Clientul (doar persoane fizice) cu numele extras va primi un premiu daca a plasat pana acum prin intermediul
--acestei firme de curierat un numar minim de comenzi X (specificat) cu o valoare totala mai mare decat o suma Y(specificata).
--Verificati daca clientul extras este valid si afisati un mesaj in caz contrar. Asigurati-va ca datele primite sunt valide (exista clientul, este unic, X si Y au sens).
--In cazul clientilor valizi se vor afisa id-ul, numele complet, email-ul, numarul de comenzi si valoarea lor totala.

CREATE OR REPLACE PROCEDURE ex9 (client_name customers_natural_persons.last_name%TYPE,
                                 no_orders_required NUMBER, total_price_required FLOAT) IS

c_id customers.customer_id%TYPE;
fn customers_natural_persons.first_name%TYPE;
ln customers_natural_persons.last_name%TYPE;
email customers.email%TYPE;
no_orders NUMBER;
total_price FLOAT;

invalid_customer EXCEPTION; --no_orders<no_orders_required OR total_price<total_price_required
invalid_no_orders_req EXCEPTION;
invalid_total_price_req EXCEPTION;

BEGIN
    IF total_price_required<=0 THEN 
        RAISE invalid_total_price_req;
    END IF;
    IF no_orders_required<1 THEN 
        RAISE invalid_no_orders_req;
    END IF;

    SELECT c.customer_id, cnp.first_name, cnp.last_name, c.email, COUNT(*), SUM(o.price+dp.price+round((o.weight_code*o.price)/100,2))
    INTO c_id, fn, ln, email, no_orders, total_price 
    FROM customers_natural_persons cnp JOIN customers c ON (c.customer_id=cnp.customer_id)
                                       JOIN orders o ON (o.customer_id=c.customer_id)
                                       JOIN weight_codes wc ON (wc.weight_code=o.weight_code)
                                       JOIN delivery_prices dp ON (dp.delivery_price_id=o.delivery_price_id)
    WHERE UPPER(cnp.last_name)=UPPER(client_name)
    GROUP BY c.customer_id, cnp.first_name, cnp.last_name, c.email;
    
    IF no_orders<no_orders_required OR total_price<total_price_required THEN
        RAISE invalid_customer;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('The customer with id ' || c_id ||', named ' || fn || ' ' || ln || ', email address: ' || email
                         || ' placed ' || no_orders|| ' order(s) with total price of: ' || total_price || ' lei.');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008,'This customer does not exist!');
   WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20009,'There are multiple customers with this name!');
   WHEN invalid_customer THEN 
        DBMS_OUTPUT.PUT_LINE('This customer is not valid!');
   WHEN invalid_total_price_req THEN
       RAISE_APPLICATION_ERROR(-20010,'Invalid total price required! It should be a positive number!');
   WHEN invalid_no_orders_req THEN
         RAISE_APPLICATION_ERROR(-20011,'Invalid number of orders required! It should be at least 1!');
 
END;
/

BEGIN
    ex9('horea', 1, 300); --The customer with id 3, named George Horea, email address: georh@gmail.com placed 1 order(s) with total price of: 326 lei.
END;
/

BEGIN
    ex9('horea', 1, 600); --This customer is not valid!
END;
/

BEGIN
    ex9('dinu', 1, 20); --error: There are multiple customers with this name!
END;
/

BEGIN
    ex9('popescu', 1, 300); --erorr: This customer does not exist!
END;
/

BEGIN
    ex9('deen', -4, 50);--error: Invalid number of orders required! It should be at least 1!
END;
/

BEGIN
    ex9('deen', 2, 0);--error: Invalid total price required! It should be a positive number!
END;
/


--Enunt trigger ex10: Creati un trigger astfel incat sa nu poata fi in tabelul "bonus" mai mult de 5 bonusuri sau mai putin de 2 bonusuri.

CREATE OR REPLACE TRIGGER ex10
    BEFORE INSERT OR DELETE ON bonus
DECLARE
no_bonuses NUMBER;

BEGIN

SELECT COUNT(*)
INTO no_bonuses
FROM bonus;

IF DELETING AND no_bonuses=2 THEN
    RAISE_APPLICATION_ERROR(-20005, 'There should be at least 2 bonuses!');
ELSIF INSERTING AND no_bonuses=5 THEN
    RAISE_APPLICATION_ERROR(-20006, 'There should be at most 5 bonuses!');
END IF;
END;
/

INSERT INTO bonus VALUES(6,10,500); --There should be at most 5 bonuses!


--Enunt trigger ex11: Sa se afiseze o eroare atunci cand in urma modificarii salariului sau bonusului pentru un curier care a avut cele mai multe expedieri ("shipments")
--acesta are un venit total (salariu+salariu*procent_bonus/100) mai mic decat cel mediu.

CREATE OR REPLACE TRIGGER ex11
    BEFORE UPDATE OF salary, bonus_id ON couriers
    FOR EACH ROW
DECLARE

PRAGMA autonomous_transaction; --mutating table problem        
max_shipments NUMBER;
no_shipments NUMBER;
avg_income FLOAT;
new_percentage bonus.percentage%TYPE;
curr_income FLOAT;

BEGIN

            SELECT COUNT(*) 
            INTO no_shipments
            FROM shipments
            WHERE courier_id=:NEW.courier_id;
            
            SELECT MAX(COUNT(*)) 
            INTO max_shipments
            FROM shipments
            GROUP BY courier_id;
            
            SELECT AVG(salary+(nvl(percentage,0)*salary)/100)
            INTO avg_income
            FROM couriers c LEFT JOIN bonus  b USING(bonus_id);
            
            --calculate current income based on new bonus percentage and new salary
            IF :NEW.bonus_id is null THEN 
                new_percentage:=0;
                curr_income:=:NEW.salary;
            ELSE 
                SELECT percentage
                INTO new_percentage
                FROM  bonus
                WHERE bonus_id =:NEW.bonus_id;
                
                curr_income:=:NEW.salary+ (:NEW.salary*new_percentage)/100;
             END IF;   

            IF no_shipments=max_shipments AND curr_income < avg_income  THEN
                    RAISE_APPLICATION_ERROR(-20000, 'This courier delivered the most shipments and he/she cannot have this small income!');
            END IF;

END;
/

UPDATE couriers 
SET bonus_id=null  -- or salary=1600
WHERE courier_id=1;
--This courier delivered the most shipments and he/she cannot have this small income! 

UPDATE couriers 
SET bonus_id=3
WHERE courier_id=1;

rollback;

UPDATE couriers 
SET bonus_id=null
WHERE courier_id=100; -- this courier does not exist => 0 rows updated

--Enunt trigger ex12: Tineti evidenta operatiilor LDD asupra schemei intr-un tabel ("audit_table").

CREATE TABLE audit_table
(
    event_id NUMBER PRIMARY KEY,
    username VARCHAR2(100) NOT NULL,
    date_event DATE NOT NULL,
    event VARCHAR2(50) NOT NULL,
    object_name VARCHAR2(100) NOT NULL
);

CREATE SEQUENCE  seq_audit_id  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE ;

CREATE OR REPLACE PROCEDURE add_to_audit_table(event_id NUMBER, username VARCHAR2, date_event DATE, event VARCHAR2, object_name VARCHAR2) IS
BEGIN
    INSERT INTO audit_table VALUES(event_id,username,date_event,event,object_name);
END;
/

CREATE OR REPLACE TRIGGER ex12
    AFTER DROP OR ALTER OR CREATE ON SCHEMA
BEGIN
    add_to_audit_table(seq_audit_id.NEXTVAL, user, sysdate, ora_sysevent, SYS.dictionary_obj_name);
END;
/

CREATE TABLE exemple
(
    val NUMBER PRIMARY KEY
);

DROP TABLE exemple;

SELECT * FROM audit_table;
   
--ex13

CREATE OR REPLACE PACKAGE ex13 IS

PROCEDURE ex6;
PROCEDURE ex7;
FUNCTION ex8(courier_id_given couriers.courier_id%TYPE) RETURN NUMBER;
PROCEDURE ex9 (client_name customers_natural_persons.last_name%TYPE,
               no_orders_required NUMBER, total_price_required FLOAT);
PROCEDURE add_to_audit_table(event_id NUMBER, username VARCHAR2, date_event DATE, event VARCHAR2, object_name VARCHAR2);
END ex13;
/


CREATE  OR REPLACE PACKAGE BODY ex13 IS

PROCEDURE ex6 IS

TYPE t_countries IS TABLE OF addresses.country_name%TYPE INDEX BY PLS_INTEGER; --index-by-table
TYPE t_no_orders IS TABLE OF NUMBER INDEX BY PLS_INTEGER; --index-by-table
TYPE t_cities IS TABLE OF addresses.city_name%TYPE; --nested table
TYPE t_total_cities IS TABLE OF t_cities; --nested table

v_countries t_countries;
v_cities t_total_cities:=t_total_cities();
v_no_orders t_no_orders;

no_countries NUMBER;
no_cities NUMBER;

BEGIN

SELECT DISTINCT a.country_name, COUNT(*)
BULK COLLECT INTO v_countries, v_no_orders
FROM orders o JOIN addresses a ON o.destination_address_id=a.address_id
GROUP BY a.country_name
ORDER BY 1 DESC;

no_countries:=v_countries.COUNT;

FOR i IN 1..no_countries LOOP --for each country
    v_cities.EXTEND;
    
    SELECT DISTINCT a.city_name
    BULK COLLECT INTO v_cities(i)
    FROM orders o JOIN addresses a ON o.destination_address_id=a.address_id
    WHERE a.country_name=v_countries(i);
END LOOP;

DBMS_OUTPUT.PUT_LINE('Countries: ');

FOR i IN 1..no_countries LOOP --for each country
    DBMS_OUTPUT.PUT(v_countries(i) || ' has ' || v_no_orders(i));
    IF v_no_orders(i)=1 THEN
        DBMS_OUTPUT.PUT(' order in ');
    ELSE     
        DBMS_OUTPUT.PUT(' orders in ');
    END IF;
    
    DBMS_OUTPUT.PUT(v_cities(i).COUNT);
    IF v_cities(i).COUNT=1 THEN
        DBMS_OUTPUT.PUT(' city: ');
    ELSE     
        DBMS_OUTPUT.PUT(' cities: ');
    END IF;
    
    --print cities 
    no_cities:=v_cities(i).COUNT;
    FOR j IN 1..no_cities-1 LOOP
        DBMS_OUTPUT.PUT( v_cities(i)(j)|| ', ');
    END LOOP;
    DBMS_OUTPUT.PUT( v_cities(i)(no_cities)|| '.');
    
    DBMS_OUTPUT.NEW_LINE;    
END LOOP;

END ex6;

PROCEDURE ex7 IS

CURSOR acc IS
           SELECT co.courier_id cour_id, co.first_name fn, co.last_name ln, ah.accident_date acc_date, cr.car_id car_id,
                  cr.brand brand, co.hire_date h_date, ch.date_start_usage start_date, co.date_start_usage_car start_date2
           FROM couriers co JOIN accidents_history ah ON co.courier_id=ah.courier_id
                 JOIN cars cr ON ah.car_id=cr.car_id
                 LEFT JOIN cars_history ch ON (ah.car_id=ch.car_id AND ah.courier_id=ch.courier_id
                                        AND ah.accident_date<=ch.date_end_usage AND ah.accident_date>=ch.date_start_usage )
            ORDER BY acc_date;        
period FLOAT;
is_current_car VARCHAR2(10);
unit_time VARCHAR2(10);

BEGIN
FOR i IN acc LOOP
    --decide if the car is the current one or an old one
    IF i.start_date IS NULL THEN
        period:=i.acc_date-i.start_date2; --current car
        is_current_car:='current ';
    ELSE
        period:=i.acc_date-i.start_date; --car driven in past
        is_current_car:='';
    END IF;
    --convert period to days, months or years
    IF period<=30 THEN
        unit_time:=' days';
    ELSIF period<=365 THEN
        unit_time:=' months';
        period:=ROUND(period/30);
    ELSE
        unit_time:=' years';
        period:=ROUND(period/365);
    END IF;
    DBMS_OUTPUT.PUT_LINE('Courier no. ' || i.cour_id || ' (' || i.fn || ' ' || i.ln || ') '
    || 'was involved in an accident on ' || i.acc_date || ' with ' || is_current_car ||  'car no. ' || i.car_id || ' (' || i.brand
    || ') ' || 'that he/she had been driving for almost ' || period || unit_time || '.' );
END LOOP;

END ex7;

FUNCTION ex8(courier_id_given couriers.courier_id%TYPE) RETURN NUMBER IS

--for a given courier: find all orders delivered and the number of products deivered from those orders 
CURSOR c(c_id couriers.courier_id%TYPE) IS 
    SELECT o.order_id order_id, SUM(sco.no_products_delivered) no_products_delivered
    FROM orders o  JOIN shipments_contain_orders sco ON o.order_id=sco.order_id 
                   JOIN shipments s ON s.shipment_id=sco.shipment_id
    WHERE sco.status='success' AND s.courier_id=c_id
    GROUP BY o.order_id;
    
CURSOR total_shipments(c_id couriers.courier_id%TYPE) IS
    SELECT shipment_id
    FROM shipments
    WHERE courier_id=c_id;
    
no_orders NUMBER:=0;
no_products_total NUMBER;
c_exists NUMBER;
shipment_id_current shipments.shipment_id%TYPE;

not_existing_courier EXCEPTION;
not_existing_orders EXCEPTION;

BEGIN

--check if the courier_id exists
SELECT COUNT(*)
INTO c_exists
FROM couriers c_table
WHERE c_table.courier_id=courier_id_given;

IF c_exists=0 THEN 
    RAISE not_existing_courier;
END IF;

--check if the courier has any orders first
OPEN total_shipments(courier_id_given);
    LOOP
        FETCH total_shipments INTO shipment_id_current;  
        EXIT WHEN total_shipments%NOTFOUND;
    END LOOP;    
    
    IF total_shipments%rowcount=0 THEN
         CLOSE total_shipments;
         RAISE not_existing_orders;
    END IF;
    
CLOSE total_shipments;

FOR i IN c(courier_id_given) LOOP
    
    SELECT o.no_products_ordered
    INTO no_products_total
    FROM orders o 
    WHERE o.order_id=i.order_id;
    IF no_products_total=i.no_products_delivered THEN 
        no_orders:=no_orders+1;
    END IF;
END LOOP;

RETURN no_orders;

EXCEPTION
    WHEN not_existing_courier THEN
        RAISE_APPLICATION_ERROR(-20015,'There is no courier with the given id!');
     WHEN not_existing_orders THEN   
        DBMS_OUTPUT.PUT_LINE('The courier given has no orders at all!');
        RETURN 0;
END ex8;

PROCEDURE ex9 (client_name customers_natural_persons.last_name%TYPE,
                                 no_orders_required NUMBER, total_price_required FLOAT) IS

c_id customers.customer_id%TYPE;
fn customers_natural_persons.first_name%TYPE;
ln customers_natural_persons.last_name%TYPE;
email customers.email%TYPE;
no_orders NUMBER;
total_price FLOAT;

invalid_customer EXCEPTION; --no_orders<no_orders_required OR total_price<total_price_required
invalid_no_orders_req EXCEPTION;
invalid_total_price_req EXCEPTION;

BEGIN
    IF total_price_required<=0 THEN 
        RAISE invalid_total_price_req;
    END IF;
    IF no_orders_required<1 THEN 
        RAISE invalid_no_orders_req;
    END IF;

    SELECT c.customer_id, cnp.first_name, cnp.last_name, c.email, COUNT(*), SUM(o.price+dp.price+round((o.weight_code*o.price)/100,2))
    INTO c_id, fn, ln, email, no_orders, total_price 
    FROM customers_natural_persons cnp JOIN customers c ON (c.customer_id=cnp.customer_id)
                                       JOIN orders o ON (o.customer_id=c.customer_id)
                                       JOIN weight_codes wc ON (wc.weight_code=o.weight_code)
                                       JOIN delivery_prices dp ON (dp.delivery_price_id=o.delivery_price_id)
    WHERE UPPER(cnp.last_name)=UPPER(client_name)
    GROUP BY c.customer_id, cnp.first_name, cnp.last_name, c.email;
    
    IF no_orders<no_orders_required OR total_price<total_price_required THEN
        RAISE invalid_customer;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('The customer with id ' || c_id ||', named ' || fn || ' ' || ln || ', email address: ' || email
                         || ' placed ' || no_orders|| ' order(s) with total price of: ' || total_price || ' lei.');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008,'This customer does not exist!');
   WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20009,'There are multiple customers with this name!');
   WHEN invalid_customer THEN 
        DBMS_OUTPUT.PUT_LINE('This customer is not valid!');
   WHEN invalid_total_price_req THEN
       RAISE_APPLICATION_ERROR(-20010,'Invalid total price required! It should be a positive number!');
   WHEN invalid_no_orders_req THEN
         RAISE_APPLICATION_ERROR(-20011,'Invalid number of orders required! It should be at least 1!');
 
END ex9;

PROCEDURE add_to_audit_table(event_id NUMBER, username VARCHAR2, date_event DATE, event VARCHAR2, object_name VARCHAR2) IS
BEGIN
    INSERT INTO audit_table VALUES(event_id,username,date_event,event,object_name);

END add_to_audit_table;


END ex13;
/


--exemplu apelare procedura din pachet
BEGIN
    ex13.ex7();
END;
/


--Enunt ex14:Creati un pachet care sa trateze urmatoarea situatie: In cazul in care profitul pe anul 2021 a fost mai mare decat cel din 2020, mariti salariile 
--primilor 3 curieri care au livrat cele mai multe pachete cu 10% si afisati informatii despre acestia (id, nume, numar de pachete livrate);
--in caz contrar, mariti preturile de livrare ("delivery_prices") cu 20% si afisati care ar fi fost profitul pe 2021 cu aceste noi preturi.

CREATE OR REPLACE PACKAGE ex14 IS
    TYPE couriers_obj_type IS RECORD
    (
        courier_id NUMBER,
        last_name VARCHAR2(50),
        no_packages_delivered NUMBER 
    );
    TYPE best_couriers IS TABLE OF couriers_obj_type;
   
    FUNCTION profit_from_orders(year_given NUMBER) RETURN NUMBER;
    FUNCTION get_best_couriers RETURN best_couriers;
    PROCEDURE raise_salary;
    PROCEDURE increase_delivery_prices;
    PROCEDURE make_changes;

END ex14;
/

CREATE OR REPLACE PACKAGE BODY ex14 IS

    FUNCTION profit_from_orders(year_given NUMBER) RETURN NUMBER IS
    total_profit NUMBER;
    no_orders_found EXCEPTION;
    BEGIN
            SELECT SUM((o.price*wc.extra_price_percentage)/100 + dp.price)
            INTO total_profit
            FROM orders o JOIN weight_codes wc USING (weight_code)
                            JOIN delivery_prices dp USING (delivery_price_id)
            WHERE EXTRACT(YEAR FROM (o.order_date))=year_given;
            
    IF total_profit IS NULL THEN 
        RAISE no_orders_found;
    END IF;    
    
    RETURN total_profit;        
            
    EXCEPTION
        WHEN no_orders_found THEN 
            DBMS_OUTPUT.PUT_LINE('There are no orders placed in this year!');
            RETURN 0;
    
    END profit_from_orders;
    
    FUNCTION get_best_couriers RETURN best_couriers IS
    CURSOR packages_couriers IS
                       SELECT t.courier_id, t.last_name, SUM(t.no_packages) total_packages_delivered
                       FROM
                      (SELECT courier_id, last_name, shipment_id, COUNT(*) no_packages
                      FROM shipments JOIN shipments_contain_orders USING (shipment_id)
                                     JOIN couriers USING(courier_id)
                      WHERE status='success'        
                      GROUP BY shipment_id, courier_id, last_name) t
                      GROUP BY t.courier_id, t.last_name
                      ORDER BY 3 DESC
                      FETCH FIRST 3 ROWS ONLY;
                        
    j NUMBER:=0;
    v_best_couriers best_couriers:=best_couriers();  
            
    BEGIN
    
    FOR i IN packages_couriers LOOP
        j:=j+1;
        v_best_couriers.EXTEND;
        v_best_couriers(j):=couriers_obj_type(i.courier_id, i.last_name, i.total_packages_delivered); --add object to nested table
    END LOOP;
    
    RETURN v_best_couriers;
    
    END get_best_couriers;
        
    
    PROCEDURE raise_salary IS
    v_couriers best_couriers;
    BEGIN
    
    v_couriers:=get_best_couriers; --call procedure from this package
    
    FOR i IN 1..v_couriers.COUNT LOOP
        UPDATE couriers SET salary=ROUND(salary+salary*0.1)
        WHERE courier_id=v_couriers(i).courier_id;
        
        DBMS_OUTPUT.PUT_LINE('Courier no. ' || v_couriers(i).courier_id || ', named ' || v_couriers(i).last_name
                             || ' got a raise of 10% because he placed top-3 in number of packages delivered with '
                             || v_couriers(i).no_packages_delivered|| ' packages.');
        
    END LOOP;
    
    END raise_salary;
    
    PROCEDURE increase_delivery_prices IS
    BEGIN
        UPDATE delivery_prices
        SET price=price+price*0.2;
         
    END increase_delivery_prices;
    
    
    PROCEDURE make_changes IS
    v_profit_2020 FLOAT;
    v_profit_2021 FLOAT;
    
    BEGIN
        v_profit_2020:=profit_from_orders(2020);
        v_profit_2021:=profit_from_orders(2021);
        
        IF v_profit_2021>v_profit_2020 THEN 
            raise_salary;
        ELSE 
            increase_delivery_prices;
            DBMS_OUTPUT.PUT_LINE('Profit after changes would have been ' || profit_from_orders(2021) || ' instead of '
                                  || v_profit_2021 || '.');
        END IF;
    
    END make_changes;
    
END ex14;
/

BEGIN
    ex14.make_changes;
END;
/


         


