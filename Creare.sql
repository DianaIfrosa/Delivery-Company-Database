CREATE TABLE delivery_prices 
(
delivery_price_id NUMBER PRIMARY KEY,
price NUMBER NOT NULL,
area VARCHAR2(300) NOT NULL
);

CREATE TABLE bonus
(
    bonus_id NUMBER PRIMARY KEY,
    percentage NUMBER CHECK(percentage>0)  NOT NULL,
    minimum_packages_required NUMBER NOT NULL CHECK(minimum_packages_required >0)
);

CREATE TABLE weight_codes
(
    weight_code NUMBER PRIMARY KEY,
    minimum_weight NUMBER NOT NULL, -- mai mare egal
    maximum_weight NUMBER NOT NULL, -- mai mic strict
    extra_price_percentage NUMBER NOT NULL
);

CREATE TABLE addresses
(
    address_id NUMBER PRIMARY KEY,
    address VARCHAR2(200) NOT NULL,
    postal_code VARCHAR2(20) NOT NULL,
    city_name VARCHAR2(50) NOT NULL,
    country_name VARCHAR2(50) NOT NULL    		 	
);

CREATE TABLE customers
(
    customer_id NUMBER PRIMARY KEY,
    phone_number VARCHAR2(20) NOT NULL,
    type_person VARCHAR2(20) NOT NULL CHECK(type_person='juridical' OR type_person='natural'), 
    bank_account_details VARCHAR2(150),
    email VARCHAR2(50)
);

CREATE TABLE cars
(
    car_id NUMBER PRIMARY KEY,
    brand VARCHAR2(50) NOT NULL,
    fabrication_year NUMBER,
    last_check DATE
);


CREATE TABLE couriers
(
    courier_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    car_id NUMBER, --nu e not null, poate nu i s-a atribuit masina inca 
    date_start_usage_car DATE,
    salary NUMBER NOT NULL CHECK(salary>=1500),
    bonus_id NUMBER, --nu e not null, poate nu are bonus
    hire_date DATE NOT NULL,
    CONSTRAINT fk_car_courier FOREIGN KEY(car_id) REFERENCES cars(car_id) ON DELETE SET NULL,
    CONSTRAINT fk_bonus FOREIGN KEY(bonus_id) REFERENCES bonus(bonus_id) ON DELETE SET NULL
);

CREATE TABLE shipments
(
    shipment_id NUMBER PRIMARY KEY,
    shipment_date DATE NOT NULL,
    courier_id NUMBER NOT NULL,
    gasoline_cost NUMBER NOT NULL,
    CONSTRAINT fk_courier FOREIGN KEY(courier_id) REFERENCES couriers(courier_id) ON DELETE CASCADE
);

CREATE TABLE orders
(
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    order_date DATE NOT NULL,
    way_of_payment VARCHAR2(50) NOT NULL CHECK(way_of_payment='card online' OR way_of_payment='card fizic' OR way_of_payment='cash'),
    price FLOAT NOT NULL, --al pachetului, fara transport si taxe extra
    no_products_ordered NUMBER NOT NULL,
    sender_name VARCHAR2(100), --daca e null e anonim
    weight_code NUMBER NOT NULL,
    destination_address_id NUMBER NOT NULL,
    delivery_price_id NUMBER NOT NULL,
    CONSTRAINT fk_customer_order FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_weight FOREIGN KEY(weight_code) REFERENCES weight_codes(weight_code) ON DELETE CASCADE,
    CONSTRAINT fk_destination FOREIGN KEY(destination_address_id) REFERENCES addresses(address_id) ON DELETE CASCADE,
    CONSTRAINT fk_delivery_price FOREIGN KEY(delivery_price_id) REFERENCES delivery_prices(delivery_price_id) ON DELETE CASCADE
);

CREATE TABLE customers_natural_persons
(
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_customer_nat FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE customers_juridical_persons
(
    customer_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    contact_person VARCHAR2(100) NOT NULL,
    fiscal_code VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_customer_jur FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE cars_history
(
    courier_id NUMBER,
    date_start_usage DATE NOT NULL,
    date_end_usage DATE NOT NULL,
    car_id NUMBER NOT NULL,
    PRIMARY KEY(courier_id, date_start_usage),
    CONSTRAINT fk_car_cars_h FOREIGN KEY(car_id) REFERENCES cars(car_id) ON DELETE CASCADE,
    CONSTRAINT fk_courier_cars_h FOREIGN KEY(courier_id) REFERENCES couriers(courier_id) ON DELETE CASCADE
);

CREATE TABLE accidents_history
(
    accident_id NUMBER PRIMARY KEY,
    courier_id NUMBER NOT NULL,
    car_id NUMBER NOT NULL,
    accident_date DATE NOT NULL,
    total_cost NUMBER NOT NULL,
    CONSTRAINT fk_car_acc_h FOREIGN KEY(car_id) REFERENCES cars(car_id) ON DELETE CASCADE,
    CONSTRAINT fk_courier_acc_h FOREIGN KEY(courier_id) REFERENCES couriers(courier_id) ON DELETE CASCADE
);

CREATE TABLE shipments_contain_orders
(
    shipment_id NUMBER,
    order_id NUMBER,
    status VARCHAR2(10) CHECK(status IS NULL OR status='success' OR status='failed'),
    no_products_delivered NUMBER NOT NULL,
    price FLOAT NOT NULL,
    feedback VARCHAR2(500),
    PRIMARY KEY(shipment_id, order_id),
    CONSTRAINT fk_tab_asoc_shipm FOREIGN KEY(shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    CONSTRAINT fk_tab_asoc_order  FOREIGN KEY(order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);