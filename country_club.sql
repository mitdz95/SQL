The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost != 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(distinct name)
FROM Facilities
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost != 0 and membercost < 0.2*monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid in (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap'
	END as label
FROM Facilities
ORDER by 2

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = 
(SELECT max(joindate) 
FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT f.name as facility, m.firstname || ' ' || m.surname as member_name
FROM Facilities f 
JOIN Bookings b
ON f.facid = b.facid
JOIN Members m
ON m.memid = b.memid
WHERE f.name like '%Tennis Court%' and m.firstname != 'GUEST'
GROUP BY 2
ORDER BY 2

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name as facility, m.firstname || ' ' || m.surname as member_name, 
CASE WHEN m.memid = 0 THEN b.slots * f.guestcost
			ELSE b.slots * f.membercost 
			END as cost
FROM Facilities f 
JOIN Bookings b
ON f.facid = b.facid
JOIN Members m
ON m.memid = b.memid
WHERE (
			(m.memid = 0 and b.slots*f.guestcost > 30) or
			(m.memid != 0 and b.slots*f.membercost > 30)
		) and b.starttime >= '2012-09-14' and 
		b.starttime < '2012-09-15'
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select facility, member,cost
from
(select m.firstname || ' ' || m.surname as member, f.name as facility,
	case when b.memid=0 then f.guestcost*b.slots
		else f.membercost*b.slots end as cost
from members m join bookings b on m.memid=b.memid
	join facilities f on b.facid=f.facid
where b.starttime >= '2012-09-14' and
			b.starttime < '2012-09-15') as booking
where cost > 30
order by cost desc

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name as facility, sum(CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
			ELSE b.slots * f.membercost 
			END) as revenue
FROM Facilities f 
JOIN Bookings b
ON f.facid = b.facid
GROUP BY 1
having sum(case 
		when memid = 0 then b.slots * f.guestcost
		else b.slots * f.membercost
	end) < 1000
ORDER BY 2

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m.firstname, m.surname, m1.firstname as rec_firstname, m1.surname as rec_surname
FROM Members m
LEFT JOIN Members m1
ON m1.memid = m.recommendedby
ORDER BY 2, 1

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.facid, f.name, COUNT( t1.memid ) AS mem_usage
FROM (
SELECT facid, memid
FROM Bookings
WHERE memid !=0
) AS t1
LEFT JOIN Facilities f ON t1.facid = f.facid
GROUP BY t1.facid

/* Q13: Find the facilities usage by month, but not guests */

SELECT t1.months, COUNT( t1.memid ) as mem_usage
FROM (
SELECT strftime('%m', starttime ) as months, memid
FROM Bookings
WHERE memid !=0
) as t1
GROUP BY 1
