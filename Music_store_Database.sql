

--Creating Database

create database music_database

use music_database

--All Tables
select * from [dbo].[album]

select * from [dbo].[artist]

select * from [dbo].[customer]

select * from [dbo].[employee]

select * from [dbo].[genre]

select * from [dbo].[invoice]

select * from [dbo].[invoice_line]

select * from [dbo].[media_type]

select * from [dbo].[playlist]

select * from [dbo].[playlist_track]

select * from [dbo].[track]




--Who is the senior most employee based on job title?

select
	  TOP 1	
	  concat(first_name,' ',last_name) as [Employee_Name]
from 
	employee
order by
	levels desc




--Which countries have the most Invoices?

select 
	  billing_country,count(*) as [Total_invoices]
from 
	invoice
group by billing_country
order by count(*) desc	




--What are top 3 values of total invoice?

select top 3
	   total 
from 
	invoice
order by 
	Total desc




--Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals

select 
	  billing_city,sum(total) as [Total_Invoice]
from 
	invoice
group by billing_city
order by sum(total) desc	




--Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the
--most money

select TOP 1
	   concat(C.first_name,' ',C.last_name) as [Customer_name],
	   sum(I.total) as [Total]
from 
	customer C 
		join
	invoice I  on C.customer_id=I.customer_id
group by concat(C.first_name,' ',C.last_name)
order by sum(total) desc




--Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A
 
select 
	  distinct C.email,
			   C.first_name,
			   C.last_name
from 
	customer C
		join
	invoice I  on C.customer_id=I.customer_id
		join
	invoice_line IL  on I.invoice_id=IL.invoice_id
Where track_id in	
					(select 
						   T.track_id 
					from
						track T
							join
						genre G  on T.genre_id=G.genre_id
					where G.name like 'Rock')
order by C.email




--Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

select TOP 10
	   Art.artist_id,
	   Art.name,
	   count(T.name) as [Track_count]
from 
	genre G
		join
	track T  on G.genre_id=T.genre_id
		join 
	album Alb  on Alb.album_id=T.album_id
		join
	artist Art  on Art.artist_id=Alb.artist_id
where G.name like 'Rock'
group by Art.artist_id,Art.name
order by count(T.name) desc
	
	
	
	
--Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first

select
	  name,
	  milliseconds 
from 
	track
where milliseconds > (select 
							avg(milliseconds)
					  from
						   track)
order by milliseconds desc	 




--Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

select 
	  concat(C.first_name,' ',C.last_name) as [Customer_name],
	  Art.name as [Artist_name],
	  sum(IL.quantity*IL.unit_price) as [Total_spent]
from 
	customer C
		join
	invoice I  on C.customer_id=I.customer_id
		join
	invoice_line IL  on I.invoice_id=IL.invoice_id
		join
	track T   on IL.track_id=T.track_id
		join 
	album Alb on T.album_id=Alb.album_id
		join
	artist Art  on Alb.artist_id=Art.artist_id
group by
		concat(C.first_name,' ',C.last_name),Art.name
order by  sum(IL.quantity*IL.unit_price) desc,Art.name




--We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres

WITH popular_genre AS
 (SELECT
        c.Country,
        g.Genre_Id,
        g.Name AS [Genre_Name],
        COUNT(il.Quantity) AS [Purchases],
        DENSE_RANK() OVER(PARTITION BY c.Country ORDER BY COUNT(il.Quantity) DESC) AS [RankNo]
    FROM Invoice_Line il
    JOIN Invoice i
        ON i.Invoice_Id = il.Invoice_Id
    JOIN Customer c
        ON c.Customer_Id = i.Customer_Id
    JOIN Track t
        ON t.Track_Id = il.Track_Id
    JOIN Genre g
        ON g.Genre_Id = t.Genre_Id
    GROUP BY
        c.Country,
        g.Genre_Id,
        g.Name)
SELECT
    Country,
    Genre_Name,
    Purchases
FROM popular_genre
WHERE RankNo = 1
ORDER BY Country, Genre_Name




--Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount

WITH Customer_With_Country AS
    (SELECT
        i.billing_country AS [Country],
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(i.total) AS [Total_Spending],
        DENSE_RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS [RankNo]
    FROM Invoice i
    JOIN Customer c
        ON c.customer_id = i.customer_id
    GROUP BY
        i.billing_country,
        c.customer_id,
        c.first_name,
        c.last_name)
SELECT
    Country,
    customer_id,
    concat(first_name,' ',last_name) AS [Customer_Name],
    Total_Spending
FROM Customer_With_Country
WHERE RankNo = 1
ORDER BY Country	








