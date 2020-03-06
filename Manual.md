---
title: Manual
---



1. 使用前的准备：

   1. 保存1DataCollection.Rmd文档到一个文件夹

   2. 在该文件夹下创建一个叫做data的文件夹。

   3. 在data文件夹下分别创建6个文件夹，依次命名为：de,hi,it,ja,ko,ru

      整个文件夹构成为：

      当前文件夹

      |--- 1DataCollection.Rmd

      |----data/

      ​		|---de/

      ​		|---it/

      ​		|---hi/

      ​		|---ja/

      ​		|---ko/

      ​		|---ru/

2. Rmd的使用说明：该Rmd文件一共包含4个R代码块，分别叫做：init, functions, demo-languages,demoen. 

   1. 打开文件之后，依次运行前两个代码块：init, functions. 

      其中，init里需要两个library: dplyr, rtweet. 适当更改library的路径参数。例如：此文件中rtweet使用library(rtweet,lib.loc="./lib/")，可能需要改为library(rtweet)

      需要设置三个参数：api_key, api_secret_key, app="..."

      在弹出的浏览器界面确定Authorize App

   2. 第三个代码块：demo-languages负责收集六个语言分别的tweet数据。调用crabbingData函数。该函数有6个参数n,queries, languages, since_ids, init_date, end_date，需要自行指定。

      使用方法：非特殊情况，只需要更新id和init_date,end_date这三个参数。如果连续抓取多天的数据，在每一天跑完后，可以用ids=last_ids进行快速的ids重设。

      文件中给了示例参数设置。在抓取不同日期的数据的时候，需要更改参数。

      参数说明：

      - n: 需要抓取的语言数量。需要与queries, languages和since_ids的数组长度相对应。比如：如果n设置为6，就表明要分别抓取6次，queries/languages/since_ids数组的长度则为6
      - queries: 一个存放多个查询语句的数组。每个元素对应于一个语言的查询语句。设置详见代码
      - languages: 一个存放多个语言编码的数组。每个元素为一个语言编码，如“it”，“hi”。设置详见代码
      - since_ids: 一个存放多个status_id的数组。每个元素为search_tweets方法的起始tweet的status_id.比如：如果想获取从2020年3月1日00：00开始的tweet，这个id应该设置2020年为2月29日最后的一个tweet的status_id.
      - init_date: 初始日期：一个长度为4的字符串，例如“0301”表示要收集3月1日的数据。如需收集3月2日的数据应将其改为“0302”，依此类推。
      - end_date: 停止日期：一个长度为10的字符串，遵循格式“%Y-%m-%d"，例如：”2020-03-02“。表示数据收集的停止日期。比如”2020-03-02“表示收集2020年3月2日之前的数据。since_ids和end_date共同决定了收集数据的时间范围：从since_ids开始，到end_date截止。

      crabbingData返回一个数组：last_ids. 表示对于每一个语言收集到的tweet数据的最后一个status_id。可用于直接更新since_ids，用作接下来一天的数据收集。如果忘记保存last_ids，可以通过：用it作示例

      load("./data/it/TweetXXXXit.RData")

      tweets$status_id[nrow(tweets)]

      进行查询，即可获得XXXX那天最后一条tweet的status_id.

      我一般会手动把last_ids的值保存到对应的语言下：见demo-languages上面的文字模块。如果是收集3月1日的数据得到的last_ids，我会把它保存到相应的3月2日的记录中，用于表示这是收集3月2日数据的since_ids。然后从六个语言的status_id中选择最大的一个作为en那一天的status_id.

   3. 第四个代码模块：demoen.这个代码块负责抓取lang="en"的数据，调用crabbingGlobal函数。因为数据量的限制，我没有抓取完整一天的数据而是当天12个小时的数据，从中午12点到晚上24点。crabbingGlobal函数有5个参数

      参数说明：

      - q: 查询语句。一般不用更改这个参数。
      - init_id：**不同于**上一个模块中的since_id，这个init_id指的是max_id。即想要收取的那一天数据的最后一个status_id。比如：想要收取3月2日的数据，这个id应该是3月2日最后一条tweet的id。怎么获取这个id呢？我的做法是，先收取各个语言3月2日的数据。然后用他们的last_ids中最大的一个来设置这个参数。
      - fdate：用作文件名的四位日期字符串。比如：想要收集3月1日的数据，就把它设置为”0301“
      - init_datetime：对应于init_id的那条tweet的created_at时间，格式为%Y-%m-%d %H:%M:%S。其实只要比end_datetime晚都有效。比如：想要收集3月2日的数据，我可以把init_datetime写为”2020-03-02 23:59:00“ 或者”2020-03-02 23:50:23“.具体是几分几秒没啥关系，只要晚于end_datetime即可。
      - end_datetime：收集停止的时间。我选择在中午12点停止。格式为："%Y-%m-%d %H"，例如："2020-03-02 12"

   我在代码中给了所有的初始化参数，应该可以直接运行。先检测能不能顺利跑完，之后每天更改参数即可。

   希望一切顺利！

