#1 Download the unzipped file first and save the zipped file to local document
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","dataset.zip")

# library to be used:
library(dplyr)

#2 Create set:
# Train set
xtrain<-read.table('./UCI HAR Dataset/train/X_train.txt', header=FALSE)
ytrain<-read.table('./UCI HAR Dataset/train/y_train.txt', header=FALSE)
# Test set
xtest<-read.table('./UCI HAR Dataset/test/X_test.txt', header=FALSE)
ytest<-read.table('./UCI HAR Dataset/test/y_test.txt', header=FALSE)
# Feature set
features<-read.table('./UCI HAR Dataset/features.txt', header=FALSE)
# Activity set
activity<-read.table('./UCI HAR Dataset/activity_labels.txt', header=FALSE)
# Subject Set
subtrain<-read.table('./UCI HAR Dataset/train/subject_train.txt', header=FALSE)
subtrain<-subtrain%>%
  rename(subjectID=V1)
subtest<-read.table('./UCI HAR Dataset/test/subject_test.txt', header=FALSE)
subtest<-subtest%>%
  rename(subjectID=V1)

# Add column names to both train and test data
features<-features[,2]
featrasp<-t(features)
colnames(xtrain)<-featrasp
colnames(xtest)<-featrasp
# rename activity columns to id and actions(walk,lay,etc.)
colnames(activity)<-c('id','actions')

#3 Merging the different dataset together
## X train
mergeX<-rbind(xtrain, xtest)

# Merging ytrain and ytest
## Y train
mergeY<-rbind(ytrain, ytest)

# Merging subject train and subject test
mergeSubj<-rbind(subtrain,subtest)

# Merging Y,X and Subject 
dfxy<-cbind(mergeY,mergeX, mergeSubj)

#Merging previous dataset with the activity
dfactivity<-merge(dfxy, activity,by.x = 'V1',by.y = 'id')

#4 Getting Mean and Standard deviation
colNames<-colnames(dfactivity)
dffinal<-dfactivity%>%
  select(actions, subjectID, grep("\\bmean\\b|\\bstd\\b",colNames))

# Transform activity to a factor variable 
dffinal$actions<-as.factor(dffinal$actions)

#5 Rename the variables
colnames(dffinal)<-gsub("^t", "time", colnames(dffinal))
colnames(dffinal)<-gsub("^f", "frequency", colnames(dffinal))
colnames(dffinal)<-gsub("Acc", "Accelerometer", colnames(dffinal))
colnames(dffinal)<-gsub("Gyro", "Gyroscope", colnames(dffinal))
colnames(dffinal)<-gsub("Mag", "Magnitude", colnames(dffinal))
colnames(dffinal)<-gsub("BodyBody", "Body", colnames(dffinal))

#6 Create a second data set with the average of each variable for activity and subject
dffinal.2<-aggregate(. ~subjectID + actions, dffinal, mean)

#7 Create the final txt file
write.table(dffinal.2, file = "tidydata.txt",row.name=FALSE)
