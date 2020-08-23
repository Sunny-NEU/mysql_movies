# mysql_movies
从 grouplens 下载数据集 MovieLens 25M Dataset。 数据集包含6个文件：
- tag.csv 用户给电影打的标签:
userId
movieId
tag
timestamp
- rating.csv 用户给电影的评分:
userId
movieId
rating
timestamp
- movie.csv 电影信息:
movieId
title
genres
- link.csv 链接到其他资源的id:
movieId
imdbId
tmbdId
- genome_scores.csv 电影和标签的相关性:
movieId
tagId
relevance
- genome_tags.csv 包含标签的描述:
tagId
tag
# 需求
读取数据集中2010年(含)到2019年(含)的数据，并将数据导入到mysql中：
1.设计数据在mysql中的schema，并使之符合三范式
- 将外键依赖删除
- 将数据导入到mysql中
- 将外键依赖恢复
2.查询数据库中的数据，统计以下信息：
为需要查询的数据创建对应的数据库索引
编写SQL回答如下问题：
- 一共有多少不同的用户
- 一共有多少不同的电影
- 一共有多少不同的电影种类
- 一共有多少电影没有外部链接
- 2018年一共有多少人进行过电影评分
- 2018年评分5分以上的电影及其对应的标签
