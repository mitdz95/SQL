1. Which countries have the most Invoices?

Use the Invoice table to determine the countries that have the most invoices. Provide a table of BillingCountry and Invoices ordered by the number of invoices for each country. The country with the most invoices should appear first.

SELECT BillingCountry, count(*) Invoice_num
FROM Invoice
GROUP BY 1
ORDER BY 2 DESC 


2. Which city has the best customers?

We want to throw a promotional Music Festival in the city we made the most money. Write a query that returns the 1 city that has the highest sum of invoice totals. Return both the city name and the sum of all invoice totals.

SELECT BILLINGCITY, SUM(TOTAL) as total
FROM INVOICE
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

3. Who is the best customer?

The customer who has spent the most money will be declared the best customer. Build a query that returns the person who has spent the most money. I found the solution by linking the following three: Invoice, InvoiceLine, and Customer tables to retrieve this information, but you can probably do it with fewer!

SELECT c.CustomerId, SUM(i.total) as total
FROM Customer c JOIN Invoice i on c.CustomerId = i.CustomerId
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

4. Use your query to return the email, first name, last name, and Genre of all Rock Music listeners (Rock & Roll would be considered a different category for this exercise). Return your list ordered alphabetically by email address starting with A.

SELECT DISTINCT c.Email, c.FirstName, c.LastName, g.Name
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
ORDER BY 1

5. Who is writing the rock music?

Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.

Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT art.ArtistId, art.Name, COUNT(t.TrackId) Songs
FROM Artist art 
JOIN Album alb ON art.ArtistId = alb.ArtistId
JOIN Track t ON alb.AlbumId = t.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10

6. First, find which artist has earned the most according to the InvoiceLines?

Now use this artist to find which customer spent the most on this artist.

For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.

SELECT   c.CUSTOMERID,
  	       c.FIRSTNAME || ' ' || c.LASTNAME AS Customer,
  	       art.NAME AS Artist,
  	       SUM(il.UNITPRICE) AS Amount_spent
FROM CUSTOMER c
JOIN INVOICE i ON c.CUSTOMERID = i.CUSTOMERID
JOIN INVOICELINE il ON i.INVOICEID = il.INVOICEID
JOIN TRACK t ON il.TRACKID = t.TRACKID
JOIN ALBUM alb ON t.ALBUMID = alb.ALBUMID
JOIN ARTIST art ON alb.ARTISTID = art.ARTISTID
WHERE art.NAME =  (SELECT ARTIST_NAME
FROM
( SELECT 	Y.NAME AS ARTIST_NAME,
          SUM(TOTAL) AS GRAND_TOTAL
FROM
          (SELECT		X.NAME,
                    X.UNITPRICE * X.QUANTITY AS TOTAL
           FROM
                   (SELECT   art.NAME,
                             il.UNITPRICE,
                             il.QUANTITY
                    FROM ARTIST art
                    JOIN ALBUM alb ON art.ARTISTID = alb.ARTISTID
                    JOIN TRACK t ON alb.ALBUMID = t.ALBUMID
                    JOIN INVOICELINE il ON t.TRACKID = il.TRACKID
                    ORDER BY 1 DESC) AS X) AS Y
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) as Z)
GROUP BY 1,2,3
ORDER BY 4 DESC

7. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres.

WITH t1 as
(
SELECT c.Country, count(i.InvoiceId) as Purchases, g.Name, g.GenreId
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY 1, 3
ORDER BY 1, 2 DESC
) 
SELECT t1.*
FROM t1
JOIN (
	SELECT Country, max(Purchases) as max, Name, GenreId
	FROM t1
	GROUP BY 1) as t2
ON t1.Country = t2.Country
WHERE t1.Purchases = t2.max

8. Return all the track names that have a song length longer than the average song length. Though you could perform this with two queries. Imagine you wanted your query to update based on when new data is put in the database. Therefore, you do not want to hard code the average into your query. You only need the Track table to complete this query.

SELECT Name, Milliseconds
FROM Track 
WHERE Milliseconds >
	(SELECT AVG(Milliseconds) as Average
	 FROM Track)
ORDER BY 2 DESC

9. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH t1 as
(SELECT c.Country, sum(i.Total) Total_spent, c.FirstName, c.LastName, c.CustomerId
FROM Customer c 
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY 5
ORDER BY 5)
SELECT t1.*
FROM t1
JOIN (
	SELECT Country, max(Total_spent) as max, FirstName, LastName, CustomerId
	FROM t1
	GROUP BY 1) as t2
ON t1.Country = t2.Country
WHERE t1.Total_spent = t2.max
ORDER BY 1