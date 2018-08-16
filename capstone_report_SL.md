# Machine Learning Engineer Nanodegree
## Capstone Project
Sifan Liu  
August 11, 2018

## I. Definition


### Project Overview
New ideas need financial resources to succeed, and many seek their initial support from crowdfunding. Research has shown 90% of successful projects on crowdfunding websites remianed ongoing ventures. 1 in 2 of the launched projects however, would fail to raise the amount they need. While the quality of the idea itself may dicate the patterns of success, funders rely on the web-presentation of the project to identify the actual quality of the idea. Therefore, many other project attributes could also potentially determine the crowdfunding success. This project aims to using these attributes to predict if a campaign would fail or succeed. 


### Problem Statement
Kickstarter is one of the leading crowd-sourcing platform focusing on early-stage funding for creative entrepreneurship. According to Kickstarter (https://www.kickstarter.com/help/stats), success rates vary across 20% - 60% for different categories. Within each category, there are significant variations in terms of the initial amount seeked, the way the project was presented/described, charateristics of the launcher (gender, city, etc. ), the size of the amount to raise, or even the planned length of the campaign. This project aims to develop a tool to help predict a project's likelihood of success upon its launch. Creators could leverage the predictions to make changes, and potentially increase their likelihood of success.  

### Metrics
I will split the data into training and testing set, first train the models on the training set and then evaluate the models by comparing their performance on the testing set. The key evaluation metrics is accuracy score, measures out of all projects, how many could the model correctly classify as success. In this specific case, the prediction doesn't have to be either high precision or high recall, so accuracy score or F1-score would suffice. 


## II. Analysis


### Data Exploration
I use the universe of the Kickstarter projects since its launch in 2009 to February, 2018. Webrobots started to web-scrap kickstarter data every month since 2014 and they've made all datasets publicly available in json and csv files (https://webrobots.io/kickstarter-datasets/). Although Kickstarter limits the amount of historic projects you can get in a single run, the active and latest projects are always included. Key variables of interest are described as follows:

Variables |Type    |Descriptions
----------|--------|-----------------------------------
Blurb     |Str     |A short description of the project
Goal      |Num     |Amount of USD asked
Pledged   |Num     |Amount of USD raised
Status    |Factor  |Five status: failed/canceled/successful/suspended/live
Slurg     |Str     |Headline of the project
Deadline  |DateTime|Time the project ended
Created   |DateTime|Time the project was created
Launched  |DateTime|Time the project went live
Creator   |Str     |First name and last name of the creator
Location  |Factor  |Town, state, country of the creator
Category  |Factor  |15 unique categories  

There are a couple charateristics needs to be noted: 
- The string variables are analyzed using Natural Language Processing. Specifically, I use sentiment analysis to determine the subjectivity and polarity of Blurb and Slug. I also use a pre-trained gender classificaiton model to assign gender information (female/male/mostly female/mostly male/unknown/andy) to creators based on their first names.
- This project wants to predict whether the 'status' of the campaign would be "failed" or "successful" when the campaign ends,  given the initial attributes of a project. Noting that "Live" projects are still in the fundraising stage and their final status is subject to change. Projects are "suspended" when the Kickstarter team uncovers evidence that it is in violation of Kickstarter's rules, and projects are "canceled" when the creators want to cease the fundraising process for any reason. The decision to suspend or cancel projects are usually independent of the project attributes, and is not what this model aims to predict. Therefore, projects with status other than “successful" or "failed" will be excluded from the dataset.
- "Goal" contains a couple extreme values that are likely to be outliers.
- Time difference between "created" and "launched" is a proxy of how much time the creator spent on preparing for the campaign; time difference between "deadline" and "launched" indicates the lenghth of fundraising decided by the creator. I will calculate both measures and include them in the model.

Stats     |goal     |life_days |prep_days|slug_plor |slug_subj|blurb_plor|blurb_subj
----------|---------|----------|---------|----------|---------|----------|------------
count	  |241717   |241717    |241717   |241717    |241717   |241717    |241717
mean	  |3.8e+04  |33.6      |43.8     |0.04      |0.17     |0.14      |0.40
std	  |1.0e+06  |12.8      |114.9    |0.19      |0.28     |0.26      |0.29
min	  |1.0e-02  |1.0       |0.0      |-1.0      |0.00     |-1.0      |0.0
25%	  |2.0e+03  |30.0      |2.0      |0.00      |0.00     |0.00      |0.16
50%	  |5.0e+03  |30.0      |10.0     |0.00      |0.00     |0.10      |0.40
75%	  |1.3e+04  |35.0      |34.0     |0.00      |0.30     |0.29      |0.59
max	  |1.0e+08  |91.0      |2313.0   |1.00      |1.00     |1.00      |1.00

### Exploratory Visualization
First I examined the distribution of outcome to predict, project status. The plot shows the number of projects by their status in each year. It's clear from the plot that the 'canceled' and 'suspended' projects represent a very small portion of the datasets in each year, and removing them from the analysis should not cause selection bias. 
![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/state_year.png)
​
While pledged amount is not included in the predictors as it is not observable at the launch of the project,it's important to understand its relationship with the project status and project goal. The following plot illustrates that successful projects raised more while asked for less, compared to failed projects. 
![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/goal_status.png)
​
Next I explored patterns of successful projects, whether the rate of success varies by category, gender and location. The crosstab suggests that projects with certain attributes tend to have higher rate of success, such as being female and located in San Franscisco. 




### Algorithms and Techniques
This is a supervised learning problem, and the prediction is a binary outcome, with successful projects coded as "1" and failed projects coded as "0". The exploratory visualization also indicates that the underlying relationship is rougly linear, so logistic algorithms would be suitable for this question. The logit output can also be interpreted as a probability, a nice feature to have for predicting the successful rate. 
​
Two additional algorithms are also utilized to compare the performance:
1. Random forest: good for both linear and non-linear models. 
2. Support Vector Machine: good for large feature sets and non-linear models
​
Scaling and normalization techniques are applied to numerical variables before fitting the models. Categorical variables are converted to dummies using one-hot-encoding.

### Benchmark
The naive predictor, in which we predict every campaign to be successful, has an accuracy score of 0.5415, and an F-1 score of 0.5962. This will serve as the main benchmark model to evaluate the model performance.

Another benchmark model is a similar project from a per-reviewed study. The author used data on all Kickstarter projects that finished between: 6/18/2012 and 11/9/2012 (Greenberg et al. 2013). The attributes used as predictors are slightly different, summarized below:
​
1. Goal in dollars of the project
2. Project category (eg. Music, or Dance, or Video Game)
3. Number of rewards available
4. Length of project in Days
5. Connected to twitter Boolean
6. Video present Boolean
7. Connected to Facebook Boolean
8. Number of facebook friends
9. Number of twitter followers
10. Sentiment (pos, neg, or neutral)
11. Number of sentences in project description
12. Outcome variable Boolean
​
The authors evaluated the performance of radial basis, polynomial and sigmoid kernel functions with varying costs for support vector machines. The also tested decision tree models with AdaBoosting. The best performing model were able to predict the success of a crowdfunding project with 68% accuracy. 


## III. Methodology
### Data Preprocessing
Key steps to process the data are:
1. Duplicated projects: the dataset is composed of data from 4 independent crawls on 2015-12-17, 2016-06-15, 2017-02-15 and 2018-02-15. Therefore, duplicated projects are checked and removed.
2. Outliers: A data point with a feature that is beyond an outlier step outside of the IQR (1.5 times) for that feature is considered abnormal. Observations with at least two abnormal features are removed from the analysis (1.4% of the entire observations)
3. Data normalization: Log transformation is applied to all numeric varaibles to achieve a normalized distribution
4. Data scaling: although logistic models and decision trees are not affected by feature scaling, SVM and CNN are still susceptible. min-max scaler is applied to all nummeric variables. 

### Implementation


### Refinement
Tuning


## IV. Results
### Model Evaluation and Validation
20% of the dataset is held for testing. The model is trained on the rest of the data, with 190,609 obseravations.
Accuracy
Time
Interpretability

![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/result.png)


All three models outperfom the accuracy score of the navie predictor (accuracy score of 0.5415, and an F-1 score of 0.5962). The logistic model achieved an accuracy score of 69%, which is very similar to the score published by the peer reviewed study. 
Random forest outperforms other models when trained on full set by a large margin. 
Large training sets. 

![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/rf_imp.png)
The normalized weights for five most predictive features in the random forests are Goal, Days spent on preparing for the campaign, Polarity of the campaign description, Subjectivity of the campgain description and lastly, Days to raise money. 





### Justification
In this section, your model’s final solution and its results should be compared to the benchmark you established earlier in the project using some type of statistical analysis. You should also justify whether these results and the solution are significant enough to have solved the problem posed in the project. Questions to ask yourself when writing this section:
- _Are the final results found stronger than the benchmark result reported earlier?_
- _Have you thoroughly analyzed and discussed the final solution?_
- _Is the final solution significant enough to have solved the problem?_


## V. Conclusion
### Reflection
One issue with the Random Forest model is that it's designed to solve the problem of prediction, not parameter estimation. If the model predicts a low success rate of a campaign, it would be helpful to also indicate what attributes are holding back the performance, and how to improve the success rate. While Random Forest does produce featuer importance, it lacks estimation of standard errors on the coefficients. 

As an experiment, I applied Logistic Regression from the stats package which gives parameter estimations on the same training set. The chart below shows the coefficients of each feature. 
![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/lg_params.png)

(discuss regression results)

Overall, I think a 81% accuracy rate meets the expectation of giving people guidance on whether their chance of getting funded successfully. Attributes that are most important to the change of success, namely campaign goal and project description, are easy fix that people can implement to increase their likelihood of success. How well this model translates to other crowdsourcing sites such as Indiegogo however, is in question as different sites might attract very different funders who may have different preferences over certain attributes. 

### Improvement
1. Image analysis: another potential attribute to include would be the characterstics of creator's profile image: would presenting a human face increase the chance of getting funded? Does the hue of the image matter? This however, requires significant storage and computing power to implement using Conventional Neural Network. 
2. Feature selection: PCA is not recommended for datasets containing a mix of continuous and categorical variables. Research has suggested using multiple correspondence analysis for mixed data types. I need more understandings of the techniques before implementing it.
