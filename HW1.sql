
# Question 1 (can it be empty)
SELECT distinct name FROM Drinkers, 
(SELECT drinker FROM Likes WHERE beer = 'Bud%')DB 
WHERE DB.drinker = phone Like '917-%';

# Question 2 
SELECT distinct beer FROM Likes WHERE drinker LIKE 'Mike';

# Question 3 (ask by towns does the assignment mean cities)
SELECT city FROM Drinkers GROUP BY city HAVING count(city) Order by count(city) desc LIMIT 1;

# Question 4
Select distinct bar From Frequents, 
(Select name FROM Drinkers WHERE city = 'New York')SC 
WHERE SC.name = Frequents.drinker;

# Question 5
Select distinct bar FROM Sells WHERE beer IN (Select beer FROM Likes WHERE drinker LIKE 'Mike');

#Question 6
Select distinct drinker FROM Likes, 
(Select distinct beer FROM Likes WHERE drinker = 'Mike' OR drinker = 'Joe')MJ 
WHERE Likes.drinker != 'Mike' and Likes.drinker != 'Joe';

#Question 7 
Select distinct F.bar FROM Sells JOIN Likes JOIN Frequents F WHERE 
Sells.bar = F.bar and F.drinker = Likes.drinker and Sells.beer = Likes.beer;

 
 #Question 8
 Select distinct drinker FROM Likes, 
 (Select beer FROM Sells WHERE bar = 'Caravan')CB
 WHERE CB.beer = Likes.beer;
 
 #Question 9 
 Select distinct b.bar FROM Likes, Frequents, (Select bar FROM Sells WHERE beer = 'Budweiser')b 
 WHERE Frequents.bar = b.bar and Frequents.drinker = Likes.drinker and Likes.beer = 'Budweiser';

 #Question 10 
 Select bar FROM Frequents WHERE Frequents.drinker = 'Mike' AND Frequents.drinker = 'Steve';
 
 #Question 11
 Select drinker from Likes, 
 (Select beer from Likes WHERE drinker = 'Mike')mb 
 WHERE Likes.beer = mb.beer and Likes.drinker != 'Mike' 
 GROUP BY Likes.drinker HAVING count(*) >= 2;
 
 #Question 12
 Select distinct s1.bar FROM Sells s1, Sells s2, Sells s3
 WHERE s1.beer in (Select beer from Likes WHERE drinker = 'Mike') 
 and s2.beer in (Select beer from Likes WHERE drinker = 'Mike')
 and s3.beer in (Select beer from Likes WHERE drinker = 'Mike')
 and s1.beer != s2.beer and s2.beer != s3.beer 
 and s3.beer != s1.beer and s1.bar = s2.bar and s2.bar = s3.bar;
 
 





