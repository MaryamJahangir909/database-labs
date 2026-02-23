-- Query 1: Machine Learning Books
SELECT title, author, rating
FROM books_read
WHERE category = 'Machine Learning';

-- Query 2: High Rated Books
SELECT title, rating
FROM books_read
WHERE rating >= 4.5
ORDER BY rating DESC;

-- Query 3: Average Pages by Category
SELECT category, AVG(pages) AS avg_pages
FROM books_read
GROUP BY category;

-- Query 4: Total Pages
SELECT SUM(pages) FROM books_read;

-- Query 5: Monthly Progress
SELECT TO_CHAR(date_finished, 'YYYY-MM') AS month,
COUNT(*)
FROM books_read
GROUP BY month;
