
ggplot2.two_y_axis <- function(g1, g2){
  g1 <- ggplotGrob(g1)
  g2 <- ggplotGrob(g2)
  
  # Get the location of the plot panel in g1.
  # These are used later when transformed elements of g2 are put back into g1
  pp <- c(subset(g1$layout, name == 'panel', se = t:r))
  
  # Overlap panel for second plot on that of the first plot
  g1 <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == 'panel')]], pp$t, pp$l, pp$b, pp$l)
  
  # Then proceed as before:
  
  # ggplot contains many labels that are themselves complex grob; 
  # usually a text grob surrounded by margins.
  # When moving the grobs from, say, the left to the right of a plot,
  # Make sure the margins and the justifications are swapped around.
  # The function below does the swapping.
  # Taken from the cowplot package:
  # https://github.com/wilkelab/cowplot/blob/master/R/switch_axis.R 
  
  hinvert_title_grob <- function(grob){
    
    # Swap the widths
    widths <- grob$widths
    grob$widths[1] <- widths[3]
    grob$widths[3] <- widths[1]
    grob$vp[[1]]$layout$widths[1] <- widths[3]
    grob$vp[[1]]$layout$widths[3] <- widths[1]
    
    # Fix the justification
    grob$children[[1]]$hjust <- 1 - grob$children[[1]]$hjust        
    grob$children[[1]]$vjust <- 1 - grob$children[[1]]$vjust 
    grob$children[[1]]$x <- unit(1, 'npc') - grob$children[[1]]$x
    grob
  }
  # Get the y axis title from g2
  index <- which(g2$layout$name == 'ylab-l') # Which grob contains the y axis title?
  ylab <- g2$grobs[[index]]        # Extract that grob
  ylab <- hinvert_title_grob(ylab)     # Swap margins and fix justifications
  
  # Put the transformed label on the right side of g1
  g1 <- gtable_add_cols(g1, g2$widths[g2$layout[index, ]$l], pp$r)
  g1 <- gtable_add_grob(g1, ylab, pp$t, pp$r + 1, pp$b, pp$r + 1, clip = 'off', name = 'ylab-r')
  
  # Get the y axis from g2 (axis line, tick marks, and tick mark labels)
  index <- which(g2$layout$name == 'axis-l')  # Which grob
  yaxis <- g2$grobs[[index]]          # Extract the grob
  
  # yaxis is a complex of grobs containing the axis line, the tick marks, and the tick mark labels.
  # The relevant grobs are contained in axis$children:
  #   axis$children[[1]] contains the axis line;
  #   axis$children[[2]] contains the tick marks and tick mark labels.
  
  # First, move the axis line to the left
  yaxis$children[[1]]$x <- unit.c(unit(0, 'npc'), unit(0, 'npc'))
  
  # Second, swap tick marks and tick mark labels
  ticks <- yaxis$children[[2]]
  ticks$widths <- rev(ticks$widths)    
  ticks$grobs <- rev(ticks$grobs)
  
  # Third, move the tick marks
  ticks$grobs[[1]]$x <- ticks$grobs[[1]]$x - unit(1, 'npc') + unit(3, 'pt')
  # Fourth, swap margins and fix justifications for the tick mark labels
  ticks$grobs[[2]] <- hinvert_title_grob(ticks$grobs[[2]])
  
  # Fifth, put ticks back into yaxis
  yaxis$children[[2]] <- ticks
  
  # Put the transformed yaxis on the right side of g1
  g1 <- gtable_add_cols(g1, g2$widths[g2$layout[index, ]$l], pp$r)
  g1 <- gtable_add_grob(g1, yaxis, pp$t, pp$r + 1, pp$b, pp$r + 1, clip = 'off', name = 'axis-r')
  grid.newpage()
  grid.draw(g1)
}


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


multiplot <- function(..., plotlist=NULL, file, cols=1,
                      layout=NULL, horizontal=FALSE, e=0.15) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots = c(list(...), plotlist)
  
  numPlots = length(plots)
  #message(paste0('>>>>>>>INFO: num plots 2 = ', numPlots), '\n')
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout = matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    
    ## set up heights/widths of plots
    
    # extra height needed for last plot (vertical layout),
    # or extra width for first plot (horizontal layout)
    hei = rep(1, numPlots)
    # bottom plot is taller
    hei[numPlots] = hei[numPlots]*(1+e)
    wid = rep(1, numPlots)
    # first left plot is wider
    wid[1] = wid[1]*(1+e)
    # Set up the page
    grid.newpage()
    if(horizontal){
      pushViewport(viewport(layout = grid.layout(nrow(layout),
                                                 ncol(layout), widths=wid)))
    }else{
      pushViewport(viewport(layout = grid.layout(nrow(layout),
                                                 ncol(layout), heights=hei)))
      
    }
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get i,j matrix positions of the regions containing this subplot
      matchidx = as.data.frame(which(layout == i, arr.ind = TRUE))
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
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