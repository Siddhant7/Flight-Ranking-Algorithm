data <- read.table(file.choose(), sep="\t", header=TRUE)
input_data <- read.table(file.choose(), sep="\t", header=TRUE)

#remove international-roundtrips
data1 <- data[-which(data[,1] == "international-roundtrip"),]

#create new column : no_of_stopovers
data1["no_of_stopovers"] <- 0
for(i in 1:nrow(data1)){
  
  if(grepl(",",data1[i,8]) == TRUE){
    data1$no_of_stopovers[i] = 2
  }
  else if(is.na(data1[i,8]) == FALSE){
    data1$no_of_stopovers[i] = 1
  }
}
#remove category, roundtrip and stopovers
data1 <- data1[,-c(1,8,9)]

data1[,7] = as.character(data1[,7])

#create new column : airline
m=as.matrix(data1[,7])
m <- apply(m, 2, function(x) substr(x, start=1, stop=2))
m=as.data.frame(m)
data1 = cbind(data1,m)
colnames(data1)[9] <- "airlines"

data2 = data1[(-which(data1$airline == "g " | data1$airline == "de"
                                      | data1$airline == "n6" | data1$airline == "81"
                                      | is.na(data1$airline) == TRUE)),]

zero_duration_index = which(data2$duration==0)
nonzero_duration_index = which(data2$duration!=0)

#imputing where duration = 0
for(i in zero_duration_index){
  
  #by transaction_id
  if(data2[i,1] %in% data2[nonzero_duration_index,1]){
    
    data2[i,5] == mean(data2[which(data2$transactionid == data2[i,1]
                                                & data2$duration!=0),5]) 
  }
  #by flight_no
  else if(length(which(data2[nonzero_duration_index,7]== data2[i,7]))!=0){
    data2[i,5] <- mean(data2[which(data2$flight_no == data2[i,7]
                                                     & data2$duration!=0),5])
  }
  #by secor
  else{
    data2[i,5] <- mean(data2[which(data2$sector == data2[i,2]
                                                     & data2$duration!=0),5])
                                                     
  }
}

zero_fare_index = which(data2$fare <=500)
nonzero_fare_index = which(data2$fare > 500)
data3 = data2
#imputing where fare < 500
for(i in zero_fare_index){
  
  if(length(which(data3$sector == data3[i,2]
                  & data3$airline == data3[i,9]
                  & data3$no_of_stopovers == data3[i,8]
                  & data3$days_to_journey==data3[i,3]
                  & data3$fare>500)) > 0){
    data3[i,6] = mean(data3[which(data3$sector == data3[i,2]
                                                    & data3$airline == data3[i,9]
                                                    & data3$no_of_stopovers == data3[i,8]
                                               & data3$days_to_journey==data3[i,3]
                                               & data3$fare>500),6])
    }else if (length(which(data3$sector == data3[i,2]
                           & data3$airline == data3[i,9]
                           & data3$no_of_stopovers == data3[i,8]
                     & data3$fare>500))>0){
     
      data3[i,6] = mean(data3[which(data3$sector == data3[i,2]
                                                      & data3$airline == data3[i,9]
                                                      & data3$no_of_stopovers == data3[i,8])
                                                      & data3$fare>500,6])
    }else if(length(which(data3$sector == data3[i,2]
                                               & data3$airline == data3[i,9]
                                               & data3$fare>500))>0){
      
      data3[i,6] = mean(data3[which(data3$sector == data3[i,2]
                                                      & data3$airline == data3[i,9]
                                                & data3$fare>500),6])
    }else{
      
      data3[i,6] = mean(data3[which(data3$sector == data3[i,2]
                                                & data3$fare>500),6])
    }
}

data4 = data3

#IMPUTATION DONE
#subset only for 21:25 days_to_journey

data4 = subset(data4, days_to_journey >= 21 & days_to_journey <= 25)


#create data frames

unique_days = unique(data4$days_to_journey)
unique_sectors = names(which(summary(data4$sector)>0))

column_names = c()
for(i in 1:length(unique_days)){
column_names = append(column_names, paste0(unique_sectors,unique_days[i]))
}

fare_mean_booking_data = data.frame(matrix(vector(), 1, length(unique_days)*length(unique_sectors),
                                     dimnames=list(c(), column_names)), stringsAsFactors=F)

fare_sd_booking_data = data.frame(matrix(vector(), 1, length(unique_days)*length(unique_sectors),
                                     dimnames=list(c(), column_names)), stringsAsFactors=F)

duration_mean_booking_data = data.frame(matrix(vector(), 1, length(unique_days)*length(unique_sectors),
                                           dimnames=list(c(), column_names)), stringsAsFactors=F)

duration_sd_booking_data = data.frame(matrix(vector(), 1, length(unique_days)*length(unique_sectors),
                                         dimnames=list(c(), column_names)), stringsAsFactors=F)


#remove outliers for every (sector+21:25 days_to_journey)
k=0
for(i in 1:length(unique_days)){
  
  for(j in 1:length(unique_sectors)){
    
    fare_quantile = quantile(data4[which(data4$days_to_journey == unique_days[i] 
                                          & data4$sector == unique_sectors[j]),6])
    fare_H <- 1.5 * IQR(data4[which(data4$days_to_journey == unique_days[i] 
                                        & data4$sector == unique_sectors[j]),6])
    fare_lower_outlier = fare_quantile[2] - fare_H
    fare_upper_outlier = fare_quantile[4] + fare_H
    
    duration_quantile = quantile(data4[which(data4$days_to_journey == unique_days[i] 
                                                  & data4$sector == unique_sectors[j]),5])
    duration_H <- 1.5 * IQR(data4[which(data4$days_to_journey == unique_days[i] 
                                             & data4$sector == unique_sectors[j]),5])
    duration_lower_outlier = duration_quantile[2] - duration_H
    duration_upper_outlier = duration_quantile[4] + duration_H
    
    k=k+1
    
    fare_mean_booking_data[1,k] = mean(data4[which(data4$fare>fare_lower_outlier 
                                                                & data4$fare<fare_upper_outlier),6],
                                       na.rm=TRUE)
    fare_sd_booking_data[1,k] = sd(data4[which(data4$fare>fare_lower_outlier 
                                                            & data4$fare<fare_upper_outlier),6],
                                   na.rm=TRUE)
    
    duration_mean_booking_data[1,k] = mean(data4[which(data4$duration>duration_lower_outlier 
                                                            & data4$duration<duration_upper_outlier),5],
                                           na.rm=TRUE)
    duration_sd_booking_data[1,k] = sd(data4[which(data4$duration>duration_lower_outlier 
                                                        & data4$duration<duration_upper_outlier),5],
                                       na.rm=TRUE)
  }
}

colnames(fare_mean_booking_data) <- gsub("[.]","-",colnames(fare_mean_booking_data))
colnames(fare_sd_booking_data) <- gsub("[.]","-",colnames(fare_sd_booking_data))
colnames(duration_mean_booking_data) <- gsub("[.]","-",colnames(duration_mean_booking_data))
colnames(duration_sd_booking_data) <- gsub("[.]","-",colnames(duration_sd_booking_data))

#TESTING

str(input_data)
test_data = input_data
unique_days_input = unique(test_data$days_to_journey)
unique_sectors_input = names(which(summary(test_data$sector)>0))

column_names_input = c()
for(i in 1:length(unique_days_input)){
  column_names_input = append(column_names_input, paste0(unique_sectors_input,unique_days_input[i]))
}

common_columns <- intersect(column_names,column_names_input)
common_columns <- intersect(common_columns,
                            colnames(fare_mean_booking_data)[-which(is.na(fare_mean_booking_data) == T)])
common_columns <- intersect(common_columns,
                            colnames(fare_sd_booking_data)[-which(is.na(fare_sd_booking_data) == T)])
common_columns <- intersect(common_columns,
                            colnames(duration_mean_booking_data)[-which(is.na(duration_mean_booking_data) == T)])
common_columns <- intersect(common_columns,
                            colnames(duration_sd_booking_data)[-which(is.na(duration_sd_booking_data) == T)])

fare_mean_booking_data <- fare_mean_booking_data[,common_columns]
fare_sd_booking_data <- fare_sd_booking_data[,common_columns]
duration_mean_booking_data <- duration_mean_booking_data[,common_columns]
duration_sd_booking_data <- duration_sd_booking_data[,common_columns]

#we will only rank for the (sector+days_remaining) combination which is present in common_columns

#change weights accordingly
fare_weight <- 0.6
duration_weight <- 0.4

test_data["no_of_stopovers"] <- 0
for(i in 1:nrow(test_data)){
  
  if(grepl(",",test_data[i,7]) == TRUE){
    test_data$no_of_stopovers[i] = 2
  }
  else if(is.na(test_data[i,7]) == FALSE){
    test_data$no_of_stopovers[i] = 1
  }
}

test_data["standardized_fare"] <- 0
test_data["standardized_duration"] <- 0
test_data["score"] <- 0

for(i in 1:nrow(test_data)){
  
  index <- which((substr(common_columns, 1,7) == test_data[i,2]) ==TRUE &
                 (as.numeric(substr(common_columns, 8,9)) == test_data[i,3]) ==TRUE) 
  
  if(length(index) == 0){
  
    test_data[i,11] <- -1
    test_data[i,12] <- -1
    test_data[i,13] <- -1
    
  }else{
    
    test_data[i,11] <- (test_data[i,6] - fare_mean_booking_data[index])/fare_sd_booking_data[index]
    test_data[i,12] <- (test_data[i,5] - duration_mean_booking_data[index])/duration_sd_booking_data[index]
    test_data[i,13] <- fare_weight*test_data[i,11] + duration_weight*test_data[i,12]
  }
    
}

#RANKING

input_sector <- "del-bom"
input_days_to_journey <- 21

testing_data <- test_data
rank_data <- testing_data[which(testing_data$sector == input_sector & 
                     testing_data$days_to_journey==input_days_to_journey),]
rank_data <- rank_data[order(rank_data$no_of_stopovers, rank_data$score),]