# 인덱스 실습

## 인덱스 실습해보기

인덱스의 특성을 더 잘 이해하기 위해 실습을 진행해보았다. 

### 사용한 데이터셋

아무래도 데이터의 갯수가 많아야 그 차이가 체감이 될 것 같아 최대한 큰 데이터 셋을 찾아보았다.

[Large-Dataset-For-MySQL](https://github.com/IshtiaqueIrteza/Large-Dataset-For-MySQL)


테스트할 테이블인 ***transaction_history***는 다음과 같다.

<img width="596" alt="table" src="https://github.com/user-attachments/assets/26e08779-7edb-41ae-bd53-afe4b267da57">  
<br>
<br>

해당 테이블은 541,909개의 데이터셋을 갖고 있다.

<img width="251" alt="1" src="https://github.com/user-attachments/assets/aafccba4-3556-45c6-9d4a-433f52586d23">
<br>
<br>

다음 sql을 입력하면 해당 테이블의 인덱스 목록을 볼 수 있다.

```sql
show index from transaction_history;
```
<br>

기본키인 ID로 인덱스가 자동생성되어 있는 것을 알 수 있다.

```
Table              |Non_unique|Key_name|Seq_in_index|Column_name|Collation|Cardinality|Sub_part|Packed|Null|Index_type|Comment|Index_comment|Visible|Expression|
-------------------+----------+--------+------------+-----------+---------+-----------+--------+------+----+----------+-------+-------------+-------+----------+
transaction_history|         0|PRIMARY |           1|ID         |A        |     539015|        |      |    |BTREE     |       |             |YES    |          |
```

### 실습 방식

1. transaction_history 테이블을 무작위 순서로 복사해서 기본 키 인덱스가 없는 테이블을 만들고
각각 Where 조건을 id로 하는 Select 쿼리를 날려 인덱스가 얼마나 영향을 미치는지 확인
2. 중복이 많은 컬럼을 인덱스로 하여서 실제로 해당 인덱스가 성능향상이 이루어지지 않는지 확인

### 실습 환경

OS: MAC

RDBMS: MySQL

DB 관리툴: DBeaber
<br>
<br>
### 1번 실습

transaction_history 테이블을 무작위 순서로 복사해서 기본 키 인덱스가 없는 테이블을 만들고
각각 Where 조건을 id로 하는 Select 쿼리를 날려 인덱스가 얼마나 영향을 미치는지 확인해보겠다.

우선 transaction_history 테이블의 데이터가 무작위 순서로 복사된 transaction_history_cp 테이블을 만들었다.

```sql
CREATE table transaction_history_cp
SELECT * FROM transaction_history order by RAND();
```

테이블이 잘 생성되었다.

<img width="1463" alt="2" src="https://github.com/user-attachments/assets/45f2f28a-f980-415b-a1a2-7076e117c48b">
<br>
<br>


당연히 기본키 제약조건을 주지 않았으므로 transaction_history_cp 테이블엔 현재 인덱스가 존재하지 않는다.

```sql
show index from transaction_history_cp;
```
<img width="844" alt="3" src="https://github.com/user-attachments/assets/948c6290-2a50-4662-aeb3-2e1b773e1ef8">
<br>
<br>

자 이제 본격적으로 실습을 진행해보겠다.

<aside>
💡 기본 키 인덱스가 생성되어있는 transaction_history테이블과 생성되어있지 않은 transaction_history_cp 테이블에 각각<br>  
    SELECT * FROM … WHERE id = 6; 이라는 쿼리를 날렸을 때 실행시간에 얼마나 차이가 나는지 확인해보겠다.
</aside>
<br>
<br>
<br>

1. transaction_history

```sql
SELECT * FROM transaction_history WHERE id = 6;
```

![1](https://github.com/user-attachments/assets/fd0f7bc6-ba70-40f3-9976-de376b02e2c3)


0.002초가 소요되었다.

1. transaction_history_cp

```sql
SELECT * FROM transaction_history_cp WHERE id = 6;
```

![2](https://github.com/user-attachments/assets/4bbd5665-c9da-4648-9cb0-d940acec4c95)


0.173초가 소요되었다. 무려 81.5배 차이가 난다.

### 결과

중복이 없는 기본 키 인덱스를 사용했을 때가 인덱스를 사용하지 않았을 때보다 쿼리 실행속도가 81.5배정도 더 빠르게 실행되었다.
<br>
<br>
### 2번 실습

중복이 많은 컬럼을 인덱스로 하여서 실제로 해당 인덱스가 성능향상에 악영향을 끼치는지 확인해보는 실습을 해보겠다.

transaction_history에서 country 컬럼은 53만개 데이터 중에서 38개의 고유한 값을 가진다.

```sql
SELECT COUNT(DISTINCT country) FROM transaction_history;
```

<img width="359" alt="3" src="https://github.com/user-attachments/assets/acb496bb-e61c-4a45-bf51-8bcd94d134b8">


이 country를 통해 인덱스를 생성해 실습해보도록 하겠다.

먼저 country를 기준으로 인덱스를 만들어줬다.

```sql
CREATE index country on transaction_history(country);
```

<img width="739" alt="4" src="https://github.com/user-attachments/assets/45edfbc0-a8ea-4faf-aed7-673e252797b2">


그리고 쿼리를 실행해주었다.

```sql
SELECT * FROM transaction_history WHERE country = 'United Kingdom';  
```

![5](https://github.com/user-attachments/assets/ed294e73-c0e9-4d97-a14d-f77510983318)


0.792초가 소요되었다.

반대로 인덱스를 다시 삭제하고 인덱스 없이 실행해보았다.

```sql
ALTER TABLE transaction_history DROP INDEX country;
SELECT * FROM transaction_history WHERE country = 'United Kingdom';  
```

<img width="200" alt="6" src="https://github.com/user-attachments/assets/2c2c1de8-50fc-4bea-a8ad-9debe2d5b84f">

오히려 인덱스를 사용하지 않았을 때가 더 빠르게 실행되었다.

### 결과

**중복이 많이 발생하는 컬럼을 통해 보조인덱스를 만들어 사용했더니 오히려 쿼리의 속도가 더 느려졌다.**
