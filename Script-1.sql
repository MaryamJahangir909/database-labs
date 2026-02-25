SELECT category,
       COUNT(*) AS total_books,
       AVG(rating) AS average_rating
FROM books_read
GROUP BY category
ORDER BY average_rating DESC;