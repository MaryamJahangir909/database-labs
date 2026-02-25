-- Lab 1: Books Read Tracker
-- Author: Maryam Jahangir
-- Create table

CREATE TABLE books_read (
book_id SERIAL PRIMARY KEY,
title VARCHAR(200) NOT NULL,
author VARCHAR(100) NOT NULL,
category VARCHAR(50),
pages INTEGER CHECK (pages > 0),
date_finished DATE,
rating DECIMAL(3,1) CHECK (rating >= 0 AND rating <= 5.0),
notes TEXT
);
