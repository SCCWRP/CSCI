#' CSCI estimator for samples taken to SAFIT Level 1
#'
#' @param mylist An output from the CSCI object (i.e., a list of dataframes)
#'
#' @return Returns the same dataframe but with new fields added to the core report, with "_MisingMidges" appended to the field name.
#' 
#' @details This function estimates maximum O/E and CSCI scores if all "missing" midges are present, i.e., SAFIT Leve 1.
#' 
#' @export
#'
MissingMidges<-function(mylist)
{
  my.core<-mylist$core
  my.oe<-mylist$Suppl1_OE

  my.core$MissingMidges_n<-sapply(my.core$SampleID, function(x)
  {
    oe.samp<-mylist$Suppl1_OE[which(my.oe$SampleID==x),]
    length(oe.samp[which(oe.samp$OTU %in% c("Tanypodinae","Orthocladiinae","Chironominae","Podonominae","Diamesinae","Telmatogetoninae") & 
                           oe.samp$CaptureProb>=0.5 & oe.samp$MeanObserved==0),"OTU"])
  })
  my.core$O_MissingMidges<-my.core$Mean_O + my.core$MissingMidges_n
  my.core$OoverE_MissingMidges<-my.core$O_MissingMidges/my.core$E
  my.core$OoverE_MissingMidges_Percentile<-round(pnorm(my.core$OoverE_MissingMidges, mean=1, sd=0.190276), digits=2)
  my.core$CSCI_MissingMidges<-(my.core$OoverE_MissingMidges+my.core$MMI)/2
  my.core$CSCI_MissingMidges_Percentile<-round(pnorm(my.core$CSCI_MissingMidges, mean=1, sd=0.160299), digits=2)
  mylist$core<-my.core
  mylist
}