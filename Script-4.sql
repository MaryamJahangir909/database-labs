SELECT title, author, rating, category
FROM books_read
WHERE (rating >= 4.5 OR category = 'Fiction')
  AND date_started >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY rating DESC;