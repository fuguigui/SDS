# Introduction

This is the course project of Social Data Science, ETH, FS 2020, opened by David Garcia.

We select the topic of checking Social Impact Theory in the COVID-19 context.

# Work

Our work mainly consists of:

- data collection: build and maintain a data pipeline to collect data from Twitter API. Keep running it since February 9, 2020 until April 21, 2020.
- hypothesis testing: we set two hypothesis, one on Strength and the other on Immediacy. We test them specifically from several degrees.
- open discussion: during this project, we find several anti-intuitive findings. We try to understand them by combining with cultural backgroud, political events, and etc.

# Repo Structure

The structure of this Git repo:

- source codes:

  - 1DataCollection.Rmd/1DataCollection_rate_limit.Rmd: how we collect the data from Twitter API. These two versions have tiny difference on rate limitation checking.

  - 2DataView.Rmd: A general view of what kind of data we have.

  - 3DataCheck.Rmd: check the correctness of the data we collect and solve possible problems.

  - 3SourceDefinition.Rmd: define all features we need for the "source" objects.

  - 3TargetDefinition.Rmd: same functions for "target" objects.
  
  - 4Immediacy_Google.Rmd: do the immediacy hypothesis testing on Google targets.
  
  - 4Immediacy_Twiiter.Rmd: do the immediacy hypothesis testing on Twitter targets.

  - 4Strength_Google.Rmd: do the strength hypothesis testing on Google targets.

  - 4Strength_twitter.Rmd: do the strength hypothesis testing on Twitter targets.

  - 4XGboost.Rmd: try to understand targets' characteristics by feature selection.

  - 5GoogleVSTwitter.Rmd: plot the timeline of Google and Twitter and further explore in differences.
  
  - 5Strength-Hypothesis.Rmd: the whole procedure of strength hypothesis testing on all of the features set.

- lib/utils.R: a script to save all of the self-defined functions used in multiple files.
- data/
  - Nodes/: all the features for the region-version of source/target definitions
  - Google/: the data we get from GoogleTrend API
  - 0421TweetsStatistics.csv: the processed Twitter impact data.
  - 0423covid19_confirmed.csv, 0423covid19_death.csv, 0423covid19_recover.csv: raw COVID19 statistics collected from the John Hopkins University's Git repo.
  - countries_location.xlsx, countries_location.csv: the latitude/longitude information of internationally administrative countries/regions.
  - world_population.json: countries' population statistics.
- raw.zip: all of the tweets data we collected. This file is too big to upload to git. You can access it by requiring.
  - en/
  - de/
  - hi/
  - it/
  - ru/
  - ko/
  - ja/
  - new/:
    - de/
    - hi/
    - it/
    - ru/
    - ko/
    - ja/

​    

Contact:

Guirong Fu: fug@student.ethz.ch

Haojun Cai: caihao@student.ethz.ch
