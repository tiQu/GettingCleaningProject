**This explains the code in run_analysis.R, submitted for the Getting and Cleaning Data course (Coursera). **

*Here are the steps of the code:*
0. Downloading, unzipping, loading required packages. Saving the date on which the data was downloaded. 
1. Reading train and test datasets into R objects, then merging the two.
2. Reading the features.txt to extract measurements on the mean and standard deviation. 
3. Reading the activity_labels.txt to replace the activity labels, dropping the now unnecessary activity names
4. Reformats and relabels the variable names in a descriptive way.
5. Creates a second tidy dataset off the first one (steps 0.-4.), which only contains the average of each variable for each activity/subject. 

Further explanatory notes can be found in the R file itself.