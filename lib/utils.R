ExtractStrengthFeature<-function(dat, pop){
  # the data is n*3 matrix(data frame)
  # row: each row represents one day. Ordered from the old to new, without missing days
  # column: accumulated confirmed, accumulated recovered, accumulated dead
  
  # daily newly absolute values
  dat_daily<-apply(dat,MARGIN = 2,diff)
  dat_daily<-as.data.frame(rbind(c(0,0,0),dat_daily))
  rownames(dat_daily)<-rownames(dat)
  colnames(dat_daily)<-colnames(dat)
  # ratio to the population
  dat_ratio_pop<-dat/pop*10000
  dat_exist<-dat$confirm-dat$recover-dat$death
  
  # relative index
  # the daily newly confirmed rate
  confirm_lagged<-dat_daily$confirm[2:nrow(dat_daily)]/dat_daily$confirm[1:(nrow(dat_daily)-1)]
  confirm_lagged[is.nan(confirm_lagged)]=0
  confirm_lagged[is.infinite(confirm_lagged)]=0
  
  #confirm_lagged[confirm_lagged==0]<-1
  dat_daily_confirm_rat<-c(0,confirm_lagged)
  
  # the death rate
  confirm_nonzero<-dat$confirm
  confirm_nonzero[confirm_nonzero==0]<-1
  dat_death_rate<-dat$death/confirm_nonzero
  
  
  # the heal rate
  dat_heal_rate<-dat$recover/confirm_nonzero
  
  # daily recoverd number/daily death number
  death_nonzero<-dat_daily$death
  death_nonzero[death_nonzero==0]<-1
  dat_risk_daily<-dat_daily$recover/death_nonzero
  
  # accumulated recovered numbr/accumulated death number
  death_nonzero<-dat$death
  death_nonzero[death_nonzero==0]<-1
  dat_risk_ttl<-dat$recover/death_nonzero
  
  dat_features<-cbind(dat,dat_daily,dat_ratio_pop,dat_exist,dat_daily_confirm_rat,dat_death_rate,dat_heal_rate,dat_risk_daily,dat_risk_ttl)
  head(dat_features)
  oldnames<-colnames(dat)
  colnames(dat_features)<-c(oldnames,sapply(oldnames,paste0,"_daily"),sapply(oldnames,paste0,"_RP"),"Exists","ConfDR","DeathR","HealR","RiskD","RiskT")
  # _RP: ratio to the total population
  # Exists: the accumulated existing case
  # ConfDR: confirm daily ratio: today's confirm/yesterday's confirm
  # DeathR: accumulated death/accumulated confirmed
  # HealR: accumulated recover/ accumulated confirmed
  # RiskD: daily risk: daily recoverd/daily death
  # RiskT: total risk: accumualted recoverd/accumulated death
  return(dat_features)
}


GetNeighData<-function(name, spath,nneigh,fs,path,start,end){
  row = spath[spath$X==name,]
  neighs = colnames(row)[row==nneigh]
  i = 1
  data_other=NULL
  for(n in neighs){
    neigh_name = fs[str_detect(fs,n)]
    other = read.csv(paste0(path,neigh_name),stringsAsFactors = F)
    if(i==1){
      data_other = other[start:end,2:ncol(other)] # 2.9 - 4.5
      i=2
    }
    else{
      data_other = data_other + other[start:end,2:ncol(other)] # 2.9
    }
  }
  return(data_other)
}



ReadCovid<-function(fname){
  #covid1<-as.data.frame(t(read.csv(paste0(path,fname),header = F, stringsAsFactors = F)),stringsAsFactors = F)
  covid1<-read.csv(paste0(path,fname),header = T, stringsAsFactors = F)
  c_names_tbl<-table(covid1$Country.Region)
  c_names_easy<-names(c_names_tbl)[c_names_tbl<2]
  c_names_hard<-setdiff(names(c_names_tbl),c_names_easy)
  covid1_easy<-filter(covid1,Country.Region%in% c_names_easy)
  covid1_hard<-filter(covid1,Country.Region%in% c_names_hard)
  
  for(c in c_names_hard){
    filter(covid1_hard,Country.Region==c) %>% select(-c("Province.State","Country.Region","Lat","Long"))%>% as.matrix -> c_subs
    c_subs = apply(c_subs, 2, as.numeric)
    apply(c_subs,MARGIN=2,FUN=sum)->new_sub_line
    new_line<-filter(covid1_hard,Country.Region==c)[1,]
    new_line[5:ncol(new_line)]<-new_sub_line
    
    covid1_easy<-rbind(covid1_easy,new_line) 
  }
  covid1<-t(select(covid1_easy,-c("Province.State","Country.Region","Lat","Long")))
  
  colnames(covid1)<-covid1_easy$Country.Region
  return(covid1)
}