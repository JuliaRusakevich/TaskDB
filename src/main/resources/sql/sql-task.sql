--1.
select aircrafts_data.model, seats.fare_conditions, count(seat_no) as count_seats
from seats
         join aircrafts_data using (aircraft_code)
group by aircrafts_data.model, seats.fare_conditions;

--2.
select aircrafts_data.model, count(seat_no) as count_seats
from seats
         join aircrafts_data using (aircraft_code)
group by aircrafts_data.model
order by count(seat_no) desc
limit 3;

--3.
select flight_no, (actual_arrival - scheduled_arrival) as flight_delay
from flights f
where age(actual_arrival, scheduled_arrival) > interval '2 hours'
  and status = 'Arrived';

--4.

with cte1 as (select book_date, book_ref
              from bookings),
     cte2 as (select ticket_no
              from ticket_flights
              where fare_conditions = 'Business'),
     cte3 as (select passenger_name, contact_data
              from tickets
                       join cte1 using (book_ref)
                       join cte2 using (ticket_no)
              group by passenger_name, contact_data, book_date
              order by book_date desc
              limit 10)
select *
from cte3;

-- 4.
select passenger_name, contact_data
from ticket_flights tf
         join tickets using (ticket_no)
         join bookings using (book_ref)
where fare_conditions = 'Business'
group by passenger_name, contact_data, book_date
order by book_date desc
limit 10;

--5.

select flight_no
from flights
where flight_id in (select flight_id
                    from ticket_flights
                    where fare_conditions = 'Business'
                    group by flight_id
                    having count(ticket_no) = 0);


-- 107642
select count(ticket_no) as sold_tickets_business
from ticket_flights
where fare_conditions = 'Business';
-- 198941
select ticket_no as all_tickets_business
from boarding_passes
         join ticket_flights using (ticket_no)
where fare_conditions = 'Business'
group by ticket_no;

--6.

select airport_name, city
from airports_data
         join flights on airports_data.airport_code = flights.departure_airport
where status = 'Delayed'
group by airport_name, city;

-- 7.

select airport_name, count(flight_id) as count_flights
from flights
         join airports_data on arrival_airport = airport_code
group by airport_name
order by count_flights desc;

-- 8.
select flight_no, scheduled_arrival, actual_arrival, age(actual_arrival, scheduled_arrival) as delay
from flights
where scheduled_arrival != actual_arrival
group by flight_no, scheduled_arrival, actual_arrival;

-- 9.

select a.aircraft_code, model, seat_no
from aircrafts_data a
         join seats using (aircraft_code)
where fare_conditions != 'Economy'
  and model ->> 'ru' = 'Аэробус A321-200'
order by seat_no;

-- 10.

select airport_code, airport_name, city
from airports_data
where city in (select city
               from airports_data
               group by city
               having count(airport_code) > 1);

-- 11.

select passenger_name, sum(total_amount) as amount
from tickets
         left join bookings using (book_ref)
group by passenger_name
having sum(total_amount) > (select avg(total_amount) from bookings);

--79025.605811528685
select avg(total_amount)
from bookings;

-- 12.

select *
from flights_v
where departure_city = 'Екатеринбург'
  and arrival_city = 'Москва'
  and status in ('On Time', 'Scheduled', 'Delayed')
order by scheduled_departure_local desc
limit 1;

select status
from flights_v
group by status;

-- 13.
select max(amount) as max_amount,
       min(amount) as min_amount
from ticket_flights;

-- 14.

create table if not exists
    bookings.customers
(
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name varchar(50)        not null,
    last_name  varchar(50)        not null,
    --email      varchar(30) check (value ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    email      varchar(50) unique not null,
    phone      varchar(20) check (length(phone) >= 9) unique
);

-- 15.

create table bookings.orders
(
    id          uuid PRIMARY key DEFAULT gen_random_uuid(),
    customer_id uuid not null,
    quantity    bigint check (quantity > 0),
    foreign key (customer_id) references bookings.customers (id)
);

-- 16.
insert into customers(first_name, last_name, email, phone)
values ('Ivan', 'Ivanov', 'ivanov@gmail.com', '336090000');

insert into customers(first_name, last_name, email, phone)
values ('Petr', 'Petrov', 'petrov@gmail.com', '336090001');

insert into customers(first_name, last_name, email, phone)
values ('Anna', 'Sidorova', 'sidorova@gmail.com');

insert into customers(first_name, last_name, email)
values ('Alex', 'Popov', 'popov@gmail.com');

insert into customers(first_name, last_name, email)
values ('Margarita', 'Koroleva', 'koroleva@gmail.com');


insert into orders (customer_id, quantity)
select customers.id, 5
from customers
where id = (select id from customers where email = 'ivanov@gmail.com');


insert into orders (customer_id, quantity)
select customers.id, 6
from customers
where id = (select id from customers where email = 'petrov@gmail.com');

insert into orders (customer_id, quantity)
select customers.id, 10
from customers
where id = (select id from customers where email = 'popov@gmail.com');

insert into orders (customer_id, quantity)
select customers.id, 10
from customers
where id = (select id from customers where email = 'koroleva@gmail.com');

-- 17.
drop table if exists bookings.orders;
drop table if exists bookings.customers;
