show databases;
USE `e-commerce`;
DROP database `e-commerce`;
show tables;


-- 인덱스 성능 테스트1
CREATE table transaction_history_cp
SELECT * FROM transaction_history order by RAND(); -- transaction_history 테이블의 데이터가 무작위 순서로 복사된 transaction_history_cp 테이블을 만들

SELECT * FROM transaction_history_cp;
show index from transaction_history_cp;
SELECT * FROM transaction_history WHERE id = 6;  
SELECT * FROM transaction_history_cp WHERE id = 6;  

-- 인덱스 성능 테스트 2
SELECT COUNT(DISTINCT country) FROM transaction_history;
show index from transaction_history;
CREATE index country on transaction_history(country);
SELECT * FROM transaction_history WHERE country = 'United Kingdom';  
ALTER TABLE transaction_history DROP INDEX country;
SELECT * FROM transaction_history WHERE country = 'United Kingdom';  
