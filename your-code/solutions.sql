## Lab | Advanced MySQL

USE publications;
SELECT * FROM publications.authors;
SELECT * FROM publications.discounts;
SELECT * FROM publications.employee;
SELECT * FROM publications.jobs;
SELECT * FROM publications.pub_info;
SELECT * FROM publications.publishers;
SELECT * FROM publications.roysched;
SELECT * FROM publications.sales;
SELECT * FROM publications.stores;
SELECT * FROM publications.titleauthor;
SELECT * FROM publications.titles;

### Challenge 1 - Most Profiting Authors: Find the TOP3 most profiting authors

-- 1) Calculate the royalty of each sale for each author and the advance for each author and publication.
SELECT 
	ta.au_id AS AUTHOR_ID, 
    ta.title_id AS TITLE_ID, 
    round(advance * t.advance * ta.royaltyper / 100) as ADVANCE,
    round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS SALES_ROYALTY
FROM publications.titleauthor AS ta
	INNER JOIN publications.titles AS t
		ON ta.title_id = t.title_id
	INNER JOIN publications.sales AS s
		ON ta.title_id = s.title_id
ORDER BY SALES_ROYALTY DESC;

-- 2) Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.
SELECT 
	TITLE_ID,
    AUTHOR_ID,
    sum(SALES_ROYALTY) AS TOTAL_ROYALTIES,
    ADVANCE
FROM
	(SELECT 
		ta.au_id AS AUTHOR_ID, 
		ta.title_id as TITLE_ID, 
		round(t.advance * ta.royaltyper / 100) as ADVANCE,
		round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS SALES_ROYALTY
	FROM publications.titleauthor AS ta
		INNER JOIN publications.titles AS t
			ON ta.title_id = t.title_id
		INNER JOIN publications.sales AS s
			ON ta.title_id = s.title_id
	ORDER BY SALES_ROYALTY DESC) tot_roy
GROUP BY tot_roy.TITLE_ID, tot_roy.AUTHOR_ID
ORDER BY TOTAL_ROYALTIES DESC;

-- 3) Using the output from Step 2 as a subquery, calculate the total profits of each author 
-- by aggregating the advances and total royalties of each title.

SELECT 
    AUTHOR_ID,
    sum(tot_prof.ADVANCE + TOTAL_ROYALTIES) AS PROFIT
FROM
	(SELECT 
		TITLE_ID,
		AUTHOR_ID,
		sum(SALES_ROYALTY) AS TOTAL_ROYALTIES,
        ADVANCE
	FROM
		(SELECT 
		ta.au_id AS AUTHOR_ID, 
		ta.title_id AS TITLE_ID, 
		round(t.advance * ta.royaltyper / 100) AS ADVANCE,
		round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS SALES_ROYALTY
		FROM publications.titleauthor AS ta
			INNER JOIN publications.titles AS t
				ON ta.title_id = t.title_id
			INNER JOIN publications.sales AS s
				ON ta.title_id = s.title_id
		ORDER BY SALES_ROYALTY DESC) tot_roy
	GROUP BY tot_roy.TITLE_ID, tot_roy.AUTHOR_ID) tot_prof
GROUP BY AUTHOR_ID
ORDER BY PROFIT DESC
LIMIT 3;