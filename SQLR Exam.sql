# 1. How many drinkers frequent only bars located in New York City

Select * FROM Bars;

Select count(drinker) FROM Frequents, 
(Select name FROM bars WHERE city = 'New York')NY 
WHERE Frequents.bar = NY.name; 

# 2 Drinkers who like at most 5 beers (you can use COUNT)

Select drinker FROM Likes GROUP BY drinker HAVING count(beer) <= 5;

Select distinct drinker, beer FROM Likes WHERE drinker = 'Mike';

Select distinct drinker, beer FROM Likes;




# 3. Are there any beers which are liked by both Ahmed and Tatiana? (return "Yes, there are" or "No, they are not'

SELECT IF((SELECT COUNT(*) FROM (
Select distinct Likes.beer FROM Likes, 
(Select beer FROM Likes WHERE drinker = 'Tatiana')TB 
WHERE drinker = 'Ahmed' and TB.beer = Likes.beer)) > 0, "Yes", "No");

Select count(beer), 

(CASE Select distinct Likes.beer FROM Likes, 
(Select beer FROM Likes WHERE drinker = 'Tatiana')TB 
WHERE drinker = 'Ahmed' and TB.beer = Likes.beer);

Select distinct  count(Likes.beer) < 0 Result , 'No there are not' FROM Likes, (Select beer FROM Likes WHERE drinker = 'Tatiana')TB 
WHERE drinker = 'Ahmed' and TB.beer = Likes.beer;

Select distinct beer FROM Likes;

Select beer FROM Likes WHERE Drinker = 'Ahmed';


# 4. Beers which are not liked by any drinker from New Brunswick 

Select distinct Likes.beer FROM Likes, 
(Select beer from Likes,(Select name FROM Drinker WHERE city = 'New Brunswick')ND 
WHERE ND.name = Likes.drinker)OT WHERE Likes.beer != OT.beer;


# 5. Bars which charge in average more than $5 per beer

Select bar, avg(price) from Sells GROUP BY Bar HAVING avg(price) > 5;

# 6.

# 7. Which precinct(s) in Penna table got the least totalvotes

Select distinct precinct, sum(totalvotes) FROM Penna 
WHERE timestamp = (Select max(timestamp) FROM Penna)
GROUP BY precinct ORDER BY sum(totalvotes) asc LIMIT 5; 

# 8. Which bars offer lowest price for Zywiec?

Select bar, price FROM Sells WHERE beer like 'Zywiec' GROUP BY bar, price ORDER BY price desc;





