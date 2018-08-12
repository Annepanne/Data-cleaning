#reading the data
xtrain <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "")
xtest <- read.csv("./UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "")
subj_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = FALSE, sep = "")
subj_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = FALSE, sep = "")
ytrain <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = FALSE, sep = "")
ytest <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = FALSE, sep = "")

activitylabels <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = "")
features <- read.csv("./UCI HAR Dataset/features.txt", header = FALSE, sep = "")

#Merging to one dataset
#first training and testing datasets. Also naming the columns
ytotal <- rbind(ytrain, ytest)
colnames(ytotal) <- c("Activitycode")

xtotal <- rbind(xtrain, xtest)
colnames(xtotal) <- features$V2

subj_tot <- rbind(subj_train, subj_test)
colnames(subj_tot) <- c("Subject")

#then merge subject, x and y datasets
total <- cbind(ytotal, subj_tot, xtotal)
 
#Extract mean  and std deviation. I'll keep the activity code and subject columns too
Activitycode <- total$Activitycode
Subject <- total$Subject
meanAndStd <- cbind(Activitycode, Subject, total[,grep("(mean\\(\\))|(std\\(\\))", colnames(total))])

#Using activity names instead of codes
meanAndStd$Activitycode <- factor(meanAndStd$Activitycode, levels = c(1,2,3,4,5,6), labels = activitylabels$V2)

#Write the clean dataset to a file
write.table(meanAndStd, file = "cleanData.csv", row.names = F, col.names = T, sep = ",")


#Creating new dataset: Averages for each variable grouped by activity and subject
avgByActivityAndSubject <- meanAndStd %>% group_by(Activitycode, Subject) %>% summarise_at(vars(-Activitycode, -Subject), funs(mean(., na.rm = T)))

#write this to file too
write.table(avgByActivityAndSubject, file = "avgByActivityAndSubject.csv", row.names = F, col.names = T, sep = ",")

#create code books. Using the package dataMaid to generate it
install.packages("dataMaid")
library(dataMaid)
#(Datamaid needs the rmarkdown package too)
install.packages("rmarkdown")
library(rmarkdown)
makeCodebook(meanAndStd)

makeCodebook(avgByActivityAndSubject)

