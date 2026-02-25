SELECT title, author, date_finished
FROM books_read
WHERE date_finished IS NOT NULL
ORDER BY date_finished DESC
LIMIT 10;