--创建表
DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
   movieId INT NOT NULL, 
   title VARCHAR (255) NOT NULL, 
   genres TEXT,
   PRIMARY KEY (movieId)
);
DROP TABLE IF EXISTS genome_scores;
CREATE TABLE genome_scores (
   genome_scores_id INT AUTO_INCREMENT,
   movieId INT NOT NULL,
   tagId INT NOT NULL,
   relevance DECIMAL (22,21) NOT NULL,
   INDEX (tagId),
   PRIMARY KEY (genome_scores_id),
   UNIQUE (movieId, tagId),
   constraint fk_genome_scores FOREIGN KEY (movieId) REFERENCES movies(movieId)
);

DROP TABLE IF EXISTS genome_tags;
CREATE TABLE genome_tags (
   tagId INT NOT NULL,
   tag VARCHAR(100) NOT NULL,
   INDEX (tagId),
   PRIMARY KEY (tagId),
   constraint fk_genome_tags FOREIGN KEY (tagId) REFERENCES genome_scores(tagId)
);

DROP TABLE IF EXISTS links;
CREATE TABLE links (
   movieId INT NOT NULL,
   imdbId INT NULL,
   tmdbId INT NULL,
   constraint fk_links FOREIGN KEY (movieId) REFERENCES movies(movieId)
);

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
   userId INT NOT NULL,
   movieId INT NOT NULL,
   rating DECIMAL(2,1) NOT NULL,
   epoch INT NOT NULL,
   constraint fk_ratings FOREIGN KEY (movieId) REFERENCES movies(movieId)
);

DROP TABLE IF EXISTS tags;
CREATE TABLE tags (
   userId INT NOT NULL,
   movieId INT NOT NULL,
   tag VARCHAR(255) NOT NULL,
   epoch INT (10) NOT NULL,
   constraint fk_tags FOREIGN KEY (movieId) REFERENCES movies(movieId)
);
--导入数据
LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/movies.csv" INTO TABLE movies FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES; 

LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/tags.csv" INTO TABLE tags FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES; 
ALTER TABLE tags ADD COLUMN timestamp TIMESTAMP;
UPDATE tags SET timestamp = FROM_UNIXTIME(epoch);--转换时间格式
ALTER TABLE tags DROP epoch;

LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/ratings.csv" INTO TABLE ratings FIELDS TERMINATED BY ',' IGNORE 1 LINES; 
ALTER TABLE ratings ADD COLUMN timestamp TIMESTAMP;
UPDATE ratings SET tishowmestamp = FROM_UNIXTIME(epoch);--转换时间格式
ALTER TABLE ratings DROP epoch;

LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/links.csv" INTO TABLE links FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(movieId, @vimdbId, @vtmdbId)
SET
imdbId = IF(CHAR_LENGTH(TRIM(@vimdbId)) = 0, NULL, @vimdbId),
tmdbId = IF(CHAR_LENGTH(TRIM(@vtmdbId)) = 0, NULL, @vtmdbId);

LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/genome-scores.csv" INTO TABLE genome_scores FIELDS TERMINATED BY ',' IGNORE 1 LINES
(movieId, tagId, relevance);

LOAD DATA INFILE "D:/MySQLdata/Uploads/ml-25m/genome-tags.csv" INTO TABLE genome_tags FIELDS TERMINATED BY ',' IGNORE 1 LINES;

--删除外键
alter table genome_scores drop constraint fk_genome_scores;
alter table genome_tags drop constraint fk_genome_tags;
alter table links drop constraint fk_links;
alter table ratings drop constraint fk_ratings;
alter table tags drop constraint fk_tags;

--恢复外键
alter table genome_scores add constraint fk_genome_scores FOREIGN KEY (movieId) REFERENCES movies(movieId);
alter table genome_tags add constraint fk_genome_tags FOREIGN KEY (tagId) REFERENCES genome_scores(tagId);
alter table links add constraint fk_links constraint fk_links FOREIGN KEY (movieId) REFERENCES movies(movieId);
alter table ratings add constraint fk_ratings constraint fk_ratings FOREIGN KEY (movieId) REFERENCES movies(movieId);
alter table tags add constraint fk_tags constraint fk_tags FOREIGN KEY (movieId) REFERENCES movies(movieId);

/*1.一共有多少不同的用户*/
select '不同用户数',sum(1)
  from
(select userId
   from  tags 
  group by userId) as a;

/*2.一共有多少种不同的电影*/
select '电影数',sum(1)
from 
	(select count(1) 
		from movies 
	 group by movieId) as a;

/*3.一共有多少不同的电影种类*/
creat temporary table movies_tmp as(
SELECT
	a.movieId,
	a.title,
	substring_index(
		substring_index(
			a.genres,
			'|',
			b.help_topic_id + 1
		),
		'|' ,- 1
	) AS genres
FROM
	 movies  a 
JOIN mysql.help_topic b ON b.help_topic_id < (
	length(a.genres) - length(
		REPLACE (a.genres, '|', '')
	) + 1
)
);

select '电影种类数',count(1)
from 
(select genres 
  from movies_tmp 
 group by genres) as a;--再根据种类字段进行去重。暂时没有想到更好的方法。

/*4.一共有多少电影没有外部链接*/
select '无链接电影数',count(*) 
  from movies t1
  left join links t2
  on t1.movieId=t2.movieId
  where t2.movieId is null;
  
/*5.2018年一共有多少人进行过电影评分*/
select '2018年评分用户数',count(1) 
  from rating 
 where timestamp like '2018%';--上面已进行过格式转换
/*6.2018年评分5分以上的电影及其对应的标签*/
select movieId,title,tag 
  from ratings t
  left join movies t1
    on t.movieId=t1.movieId
  left join tags t2
    on t.movieId=t2.movieId
  where t.rating>=5
    and t.timestamp like '2018%';



