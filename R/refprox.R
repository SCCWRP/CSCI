#' Plot reference proximity values for a test site
#'
#' @param station_dat input \code{data.frame} for the test site that includes all station data
#' @param output chr string indicating desired output from the function
#' 
#' @details 
#' \code{station_dat} must have the same GIS predictors as those in \code{bugs_stations[[2]]}, specifically 
#' \code{"StationCode", "AREA_SQKM", "New_Lat", "New_Long", "SITE_ELEV", "PPT_00_09", "TEMP_00_09", "SumAve_P", 
#' "KFCT_AVE", "BDH_AVE", "P_MEAN", "ELEV_RANGE"}. The \code{StationCode} must also not be a reference site, as 
#' in those in \code{loadRefData()}.
#' 
#' @import ggplot2
#' @importFrom magrittr %>%
#' 
#' @return 
#' A plot of average proximity values across all metrics if \code{output = "map"}, a facetted map for each 
#' model and predictor of proximity values if \code{output = "mapmod"}, a jitter plot of the distribution 
#' of proximity values by predictor if \code{output = "jit"}, a faceted jitter plot of the disributin of 
#' proximity valuues by predictor and model if \code{output = "jitmod"}, a PCA plot of principal components 
#' one and two for all metric proximity values if \code{output = "pca"}, a faceted PCA plot of principal 
#' components one and two for all metric proximity values by model if \code{output = "pcamod"}, or a 
#' \code{data.frame} of the proximity values for all reference sites and the test site if \code{output = "dat"}.
#' 
#' @export
#'
#' @examples
#' station_dat <- bugs_stations[[2]][1, ]
#' 
#' # map, default
#' refprox(station_dat)
#' 
#' # map by model
#' refprox(station_dat, output = 'mapmod')
#' 
#' # jitter
#' refprox(station_dat, output = 'jit')
#' 
#' # jitter by model
#' refprox(station_dat, output = 'jitmod')
#' 
#' # pca
#' refprox(station_dat, output = 'pca')
#' 
#' # pca by model
#' refprox(station_dat, output = 'pcamod')
#' 
#' # data
#' refdat <- refprox(station_dat, output = 'dat')
#' head(refdat)
#' tail(refdat)
refprox <- function(station_dat, output = c("map", "mapmod", "jit", "jitmod", "pca", "pcamod", "dat")){
  
  # Make sure we have the right columns
  station_dat <- station_dat %>% dplyr::select(
    StationCode, AREA_SQKM, New_Lat, New_Long, SITE_ELEV,
    PPT_00_09, TEMP_00_09, SumAve_P, KFCT_AVE, BDH_AVE,
    P_MEAN, ELEV_RANGE
  )
  
  # select output
  output <- match.arg(output)
  
  my.station <- station_dat$StationCode
  
  # Get ref data
  ref.df <- loadRefData()
  ref.stations <- as.character(ref.df$StationCode)
  
  ##
  # sanity checks
  
  # test station must not be in reference data
  if(my.station %in% ref.stations)
    stop(paste('Cannot have test station in reference data'))
  
  # station data must have all predictors
  chk <- setdiff(names(bugs_stations[[2]]), names(station_dat))
  if(length(chk) > 0)
    stop(paste('Mising station data:', paste(chk, collapse = ', ')))
  
  # cali basemap
  basemap <- ggplot(data = subset(map_data('state'), region=="california"), aes(x = long, y = lat)) +
    geom_polygon(color = NA, fill = "gray80") +  
    coord_map() + 
    theme_minimal()
  
  # load models
  oe.model <- oe_stuff[[1]]
  
  metrics <- c("Clinger_PercentTaxa", "Coleoptera_PercentTaxa", "Taxonomic_Richness", 
             "EPT_PercentTaxa", "Shredder_Taxa", "Intolerant_Percent")
  
  # Create an input matrix with all ref data and all test sites
  test.df <- ref.df
  test.df <- plyr::rbind.fill(ref.df[,c(
    "StationCode","New_Lat","New_Long", "AREA_SQKM", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "P_MEAN", "ELEV_RANGE")],
    station_dat)
  # Two predictors need to be log-transformed
  test.df$Log_P_MEAN <- log10(test.df$P_MEAN+0.00001)
  test.df$LogWSA <- log10(test.df$AREA_SQKM)
  
  # prox val to grab
  grb <- nrow(test.df)
  
  # Run each model and extract proximity matrix
  test.df$Clinger_Percent.prox <- randomForest:::predict.randomForest(final_forests$Clinger_PercentTaxa, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$Coleoptera_Percent.prox <- randomForest:::predict.randomForest(final_forests$Coleoptera_PercentTaxa, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$Taxonomic_Richness.prox <- randomForest:::predict.randomForest(final_forests$Taxonomic_Richness, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$EPT_PercentTaxa.prox <- randomForest:::predict.randomForest(final_forests$EPT_PercentTaxa, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$Shredder_Taxa.prox <- randomForest:::predict.randomForest(final_forests$Shredder_Taxa, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$Intolerant_Percent.prox <- randomForest:::predict.randomForest(final_forests$Intolerant_Percent, newdata = test.df, proximity = TRUE)$proximity[,grb]
  test.df$OE.prox <- randomForest:::predict.randomForest(oe.model, newdata = test.df, proximity = TRUE)$proximity[,grb]
  
  # For overall proximity across models, take the mean (with OE model counting for half)
  test.df$MeanProximity <-
    (rowMeans(test.df[, c("Clinger_Percent.prox","Coleoptera_Percent.prox","Taxonomic_Richness.prox","EPT_PercentTaxa.prox","Shredder_Taxa.prox","Intolerant_Percent.prox")])+
       test.df$OE.prox)/2
  
  if(output == 'dat') out <- test.df
  
  if(output == 'map'){
    
    # Mean proximity map
    out <- basemap+
      geom_point(data=test.df[which(test.df$StationCode %in% ref.stations & test.df$MeanProximity>0),], aes(x=New_Long, y=New_Lat, size=MeanProximity), shape=21, fill="gray25")+
      geom_point(data=test.df[which(test.df$StationCode %in% ref.stations & test.df$MeanProximity==0),], aes(x=New_Long, y=New_Lat, size=MeanProximity), size=0.1, color="white")+
      geom_point(data=test.df[which(test.df$StationCode %in% my.station),], aes(x=New_Long, y=New_Lat), shape=22, size=3, fill="yellow")+
      ggtitle(paste("Reference sites for",my.station))+xlab("")+ylab("")+
      scale_size_continuous(range=c(0.5,3))
  }
  
  if(output == 'mapmod'){
    
    #Proximity for each model map
    test.df.m<-reshape2::melt(test.df[,c("StationCode","New_Lat","New_Long","Clinger_Percent.prox","Coleoptera_Percent.prox","Taxonomic_Richness.prox","EPT_PercentTaxa.prox","Shredder_Taxa.prox","Intolerant_Percent.prox","OE.prox")],
                       id.vars=c("StationCode","New_Lat","New_Long"), variable.name = "Model", value.name="Proximity")
    test.df.m$Model<-gsub(".prox","", test.df.m$Model)
    test.df.m$Model<-factor(test.df.m$Model, levels=c("Clinger_Percent","Coleoptera_Percent","Taxonomic_Richness","EPT_PercentTaxa","Shredder_Taxa","Intolerant_Percent","OE"))
    
    out <- basemap+
      geom_point(data=test.df.m[which(test.df.m$StationCode %in% ref.stations & test.df.m$Proximity>0),], aes(x=New_Long, y=New_Lat, size=Proximity), shape=21, fill="gray25")+  geom_point(data=test.df.m[which(test.df.m$StationCode %in% ref.stations & test.df.m$Proximity==0),], aes(x=New_Long, y=New_Lat, size=Proximity), size=0.1, color="white")+
      geom_point(data=test.df.m[which(test.df.m$StationCode %in% ref.stations & test.df.m$Proximity==0),], aes(x=New_Long, y=New_Lat, size=Proximity), size=0.1, color="white")+
      geom_point(data=test.df.m[which(test.df.m$StationCode %in% my.station),], aes(x=New_Long, y=New_Lat), shape=22, size=3, fill="yellow")+
      facet_wrap(~Model)+
      ggtitle(paste("Reference sites for",my.station))+
      theme(axis.text=element_blank())+xlab("")+ylab("")+
      scale_size_continuous(range=c(0.5,3))
    
  }
  
  if(output == 'jit'){
    
    #Based on mean proximity (one panel per predictor, with nothing meaningful on the x axis)
    test.df.mA <- reshape2::melt(test.df[,c("StationCode","MeanProximity", "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")],
                        variable.name="Predictor", value.name="PredictorValue", id.vars=c("StationCode","MeanProximity"))
    out <- ggplot(data=test.df.mA, aes(x=Predictor, y=PredictorValue))+
      geom_jitter(data=test.df.mA[which(test.df.mA$StationCode %in% ref.stations & test.df.mA$MeanProximity==0),], aes(size=MeanProximity), size=0.1, color="gray80")+
      geom_jitter(data=test.df.mA[which(test.df.mA$StationCode %in% ref.stations & test.df.mA$MeanProximity>0),], aes(size=MeanProximity), shape=21, fill="gray25", position=position_jitter(height=0, width=0.25))+
      geom_point(data=test.df.mA[which(test.df.mA$StationCode %in% my.station),], shape=22, size=3, fill="yellow")+
      facet_wrap(~Predictor, scales="free")+
      ggtitle(paste("Reference sites for",my.station))+
      scale_size_continuous(range = c(0.5,3))+
      xlab("")+ylab("")+
      theme_classic()+theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
    
  }
  
  if(output == 'jitmod'){
    
    test.df.m<-melt(test.df[,c("StationCode","New_Lat","New_Long","Clinger_Percent.prox","Coleoptera_Percent.prox","Taxonomic_Richness.prox","EPT_PercentTaxa.prox","Shredder_Taxa.prox","Intolerant_Percent.prox","OE.prox")],
                       id.vars=c("StationCode","New_Lat","New_Long"), variable.name = "Model", value.name="Proximity")
    test.df.m$Model<-gsub(".prox","", test.df.m$Model)
    test.df.m$Model<-factor(test.df.m$Model, levels=c("Clinger_Percent","Coleoptera_Percent","Taxonomic_Richness","EPT_PercentTaxa","Shredder_Taxa","Intolerant_Percent","OE"))
    test.df.m2<-reshape2::melt(test.df[,c("StationCode", "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")],
                        variable.name="Predictor", value.name="PredictorValue")
    test.df.m3<-merge(test.df.m, test.df.m2)
    out <- ggplot(data=test.df.m3, aes(x=Model, y=PredictorValue))+
      geom_jitter(data=test.df.m3[which(test.df.m3$StationCode %in% ref.stations & test.df.m3$Proximity==0),], aes(size=Proximity), size=0.1, color="gray80")+
      geom_jitter(data=test.df.m3[which(test.df.m3$StationCode %in% ref.stations & test.df.m3$Proximity>0),], aes(size=Proximity), shape=21, fill="gray25", position=position_jitter(height=0, width=0.25))+
      geom_point(data=test.df.m3[which(test.df.m3$StationCode %in% my.station),], shape=22, size=3, fill="yellow")+
      facet_wrap(~Predictor, scales="free")+
      ggtitle(paste("Reference sites for",my.station))+
      scale_size_continuous(range = c(0.5,3))+
      xlab("")+ylab("")+
      theme_classic()+theme(axis.text.x = element_text(angle=45, hjust=1))
    
  }
    
  if(output == 'pca'){
    
    pred.df<-test.df[ c("New_Lat","New_Long",  "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")]
    pred.pca<-prcomp(pred.df, scale=T, retx=T,center=T)
    test.df<-cbind(test.df, pred.pca$x[,1:3])
    
    #Prepare labels
    pred.pca.loadings<-data.frame(pred.pca$rotation)
    pred.pca.loadings$Var<-c("New_Lat","New_Long",  "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")
    pred.pca.loadings$PC1.r<-pred.pca.loadings$PC1* (max(pred.pca$x[,1]) -min(pred.pca$x[,1]))
    pred.pca.loadings$PC2.r<-pred.pca.loadings$PC2* (max(pred.pca$x[,2]) -min(pred.pca$x[,2]))
    pred.pca.loadings$PC3.r<-pred.pca.loadings$PC3* (max(pred.pca$x[,3]) -min(pred.pca$x[,3]))
    
    #PCA for mean proximity
    out <- ggplot(test.df, aes(x=PC1, y=PC2))+
      geom_point(data=test.df[which(test.df$StationCode %in% ref.stations & test.df$MeanProximity==0),], aes(size=MeanProximity), size=0.1, color="gray80")+
      geom_point(data=test.df[which(test.df$StationCode %in% ref.stations & test.df$MeanProximity>0),], aes(size=MeanProximity), shape=21, fill="gray25")+
      geom_point(data=test.df[which(test.df$StationCode %in% my.station),], shape=22, size=3, fill="yellow")+
      theme_classic()  +
      theme(axis.text = element_blank())+
      geom_text(data=pred.pca.loadings, aes(label=Var, x=PC1.r, y=PC2.r)) #May need tweaking for legibility

  }
  
  if(output == "pcamod"){

    test.df.m<-melt(test.df[,c("StationCode","New_Lat","New_Long","Clinger_Percent.prox","Coleoptera_Percent.prox","Taxonomic_Richness.prox","EPT_PercentTaxa.prox","Shredder_Taxa.prox","Intolerant_Percent.prox","OE.prox")],
                       id.vars=c("StationCode","New_Lat","New_Long"), variable.name = "Model", value.name="Proximity")
    test.df.m$Model<-gsub(".prox","", test.df.m$Model)
    test.df.m$Model<-factor(test.df.m$Model, levels=c("Clinger_Percent","Coleoptera_Percent","Taxonomic_Richness","EPT_PercentTaxa","Shredder_Taxa","Intolerant_Percent","OE"))
    test.df.m2<-reshape2::melt(test.df[,c("StationCode", "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")],
                        variable.name="Predictor", value.name="PredictorValue")
    test.df.m3<-merge(test.df.m, test.df.m2)    
    
    pred.df<-test.df[ c("New_Lat","New_Long",  "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")]
    pred.pca<-prcomp(pred.df, scale=T, retx=T,center=T)
    test.df<-cbind(test.df, pred.pca$x[,1:3])
    
    #Prepare labels
    pred.pca.loadings<-data.frame(pred.pca$rotation)
    pred.pca.loadings$Var<-c("New_Lat","New_Long",  "LogWSA", "SITE_ELEV", "PPT_00_09","TEMP_00_09", "SumAve_P", "KFCT_AVE", "BDH_AVE", "Log_P_MEAN", "ELEV_RANGE")
    pred.pca.loadings$PC1.r<-pred.pca.loadings$PC1* (max(pred.pca$x[,1]) -min(pred.pca$x[,1]))
    pred.pca.loadings$PC2.r<-pred.pca.loadings$PC2* (max(pred.pca$x[,2]) -min(pred.pca$x[,2]))
    pred.pca.loadings$PC3.r<-pred.pca.loadings$PC3* (max(pred.pca$x[,3]) -min(pred.pca$x[,3]))
    
    #PCA for each model
    test.dfB<-merge(test.df.m3, test.df[,c("StationCode", "PC1","PC2","PC3")])
    
    out <- ggplot(test.dfB, aes(x=PC1, y=PC2))+
      geom_point(data=test.dfB[which(test.dfB$StationCode %in% ref.stations & test.dfB$Proximity==0),], aes(size=Proximity), size=0.1, color="gray80")+
      geom_point(data=test.dfB[which(test.dfB$StationCode %in% ref.stations & test.dfB$Proximity>0),], aes(size=Proximity), shape=21, fill="gray25")+
      geom_point(data=test.dfB[which(test.dfB$StationCode %in% my.station),], shape=22, size=3, fill="yellow")+
      facet_wrap(~Model)+
      theme_classic()  +theme(axis.text = element_blank())
    
  }
  
  return(out)
  
}

