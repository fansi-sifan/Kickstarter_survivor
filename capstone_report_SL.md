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
count	  |2.4e+05  |241717    |241717   |241717    |241717   |241717    |241717
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

While pledged amount is not included in the predictors as it is not observable at the launch of the project,it's important to understand its relationship with the project status and project goal. The following plot illustrates that successful projects raised more while asked for less, compared to failed projects. 
![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/goal_status.png)

Next I explored patterns of successful projects, whether the rate of success varies by category, gender and location. The crosstab suggests that projects with certain attributes tend to have higher rate of success, such as being female and located in San Franscisco. 




### Algorithms and Techniques
This is a supervised learning problem, and the prediction is a binary outcome, with successful projects coded as "1" and failed projects coded as "0". The exploratory visualization also indicates that the underlying relationship is rougly linear, so logistic algorithms would be suitable for this question. The logit output can also be interpreted as a probability, which is a nice feature to have for predicting the successful rate. 

Categorical variables will be converted to dummies using one-hot-encoding.
I will also use Random forest and CNN, which are good for both linear and non-linear models.

### Benchmark
The benchmark model used data on all projects that finished between: 6/18/2012 and 11/9/2012 (Greenberg et al. 2013). The attributes are summarized in the table below:
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
_(approx. 3-5 pages)_

### Data Preprocessing
A significant part of the analysis will be data cleaning. Key steps would include:
- check for duplicated projects
- parsing dates
- crosswalk location to Metropolitan Statistical Areas and merge with census data.
- train an algorithm to determin the gender of campaign owner based on the names (and potentially, profile pictures)
- using natural language processing to classify campagin title and description
- check for missing values
- scale and normalizae data

### Implementation
In this section, the process for which metrics, algorithms, and techniques that you implemented for the given data will need to be clearly documented. It should be abundantly clear how the implementation was carried out, and discussion should be made regarding any complications that occurred during this process. Questions to ask yourself when writing this section:
- _Is it made clear how the algorithms and techniques were implemented with the given datasets or input data?_
- _Were there any complications with the original metrics or techniques that required changing prior to acquiring a solution?_
- _Was there any part of the coding process (e.g., writing complicated functions) that should be documented?_

### Refinement
In this section, you will need to discuss the process of improvement you made upon the algorithms and techniques you used in your implementation. For example, adjusting parameters for certain models to acquire improved solutions would fall under the refinement category. Your initial and final solutions should be reported, as well as any significant intermediate results as necessary. Questions to ask yourself when writing this section:
- _Has an initial solution been found and clearly reported?_
- _Is the process of improvement clearly documented, such as what techniques were used?_
- _Are intermediate and final solutions clearly reported as the process is improved?_


## IV. Results
_(approx. 2-3 pages)_

### Model Evaluation and Validation
In this section, the final model and any supporting qualities should be evaluated in detail. It should be clear how the final model was derived and why this model was chosen. In addition, some type of analysis should be used to validate the robustness of this model and its solution, such as manipulating the input data or environment to see how the model’s solution is affected (this is called sensitivity analysis). Questions to ask yourself when writing this section:
- _Is the final model reasonable and aligning with solution expectations? Are the final parameters of the model appropriate?_
- _Has the final model been tested with various inputs to evaluate whether the model generalizes well to unseen data?_
- _Is the model robust enough for the problem? Do small perturbations (changes) in training data or the input space greatly affect the results?_
- _Can results found from the model be trusted?_

![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/result.png)

![alt text](https://github.com/fansi-sifan/Kickstarter_survivor/blob/master/plots/rf_imp.png)



### Justification
In this section, your model’s final solution and its results should be compared to the benchmark you established earlier in the project using some type of statistical analysis. You should also justify whether these results and the solution are significant enough to have solved the problem posed in the project. Questions to ask yourself when writing this section:
- _Are the final results found stronger than the benchmark result reported earlier?_
- _Have you thoroughly analyzed and discussed the final solution?_
- _Is the final solution significant enough to have solved the problem?_


## V. Conclusion
_(approx. 1-2 pages)_

### Free-Form Visualization
In this section, you will need to provide some form of visualization that emphasizes an important quality about the project. It is much more free-form, but should reasonably support a significant result or characteristic about the problem that you want to discuss. Questions to ask yourself when writing this section:
- _Have you visualized a relevant or important quality about the problem, dataset, input data, or results?_
- _Is the visualization thoroughly analyzed and discussed?_
- _If a plot is provided, are the axes, title, and datum clearly defined?_

### Reflection
In this section, you will summarize the entire end-to-end problem solution and discuss one or two particular aspects of the project you found interesting or difficult. You are expected to reflect on the project as a whole to show that you have a firm understanding of the entire process employed in your work. Questions to ask yourself when writing this section:
- _Have you thoroughly summarized the entire process you used for this project?_
- _Were there any interesting aspects of the project?_
- _Were there any difficult aspects of the project?_
- _Does the final model and solution fit your expectations for the problem, and should it be used in a general setting to solve these types of problems?_

### Improvement
In this section, you will need to provide discussion as to how one aspect of the implementation you designed could be improved. As an example, consider ways your implementation can be made more general, and what would need to be modified. You do not need to make this improvement, but the potential solutions resulting from these changes are considered and compared/contrasted to your current solution. Questions to ask yourself when writing this section:
- _Are there further improvements that could be made on the algorithms or techniques you used in this project?_
- _Were there algorithms or techniques you researched that you did not know how to implement, but would consider using if you knew how?_
- _If you used your final solution as the new benchmark, do you think an even better solution exists?_

-----------

**Before submitting, ask yourself. . .**

- Does the project report you’ve written follow a well-organized structure similar to that of the project template?
- Is each section (particularly **Analysis** and **Methodology**) written in a clear, concise and specific fashion? Are there any ambiguous terms or phrases that need clarification?
- Would the intended audience of your project be able to understand your analysis, methods, and results?
- Have you properly proof-read your project report to assure there are minimal grammatical and spelling mistakes?
- Are all the resources used for this project correctly cited and referenced?
- Is the code that implements your solution easily readable and properly commented?
- Does the code execute without error and produce results similar to those reported?
