SELECT title, author, rating, category
FROM books_read
WHERE rating > 4.0
ORDER BY rating DESC;