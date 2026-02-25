SELECT title,
       date_started,
       date_finished,
       (date_finished - date_started) AS days_to_complete
FROM books_read
WHERE date_started IS NOT NULL
  AND date_finished IS NOT NULL
ORDER BY days_to_complete ASC;