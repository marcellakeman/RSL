#!/usr/bin/env python
# coding: utf-8

# #Movie Recommender System written by Marcel Lakeman 500694128

# In[87]:


import pandas as pd
import os

#Check current working directory
wd = os.getcwd() 
print(wd)


# In[40]:


#Load data with pandas
data = pd.read_csv('userReviews all three parts.csv', sep = ';')
print(data.head())


# In[76]:


#Create subset where of the Lord of the Rings the Return of the King
#The reviewed metascore has to be 7 at least, so you know the reviewers liked the movie
lotr =  data.loc[(data['movieName'] == 'the-lord-of-the-rings-the-return-of-the-king') & (data['Metascore_w'] >= 7)]
lotr


# In[77]:


#The movie recommender system focusses on movies that reviewers have given a higher Metascore
#We need to select the reviewers from the smaller dataset and compare the review score to the other reviewed movies

#Column names for the dataset with recommended movies
c_names = ['movieName', 'Author', 'Metascore_w']

#Create the new dataframe RecoLOTR (Recommendations Lord of the Rings)
RecoLOTR = pd.DataFrame(columns = c_names)

#Create an empty list for the values 'increased metascore'
incLOTR = []

#Create two loops, one for the subset and one for the larger dataset
for a in range(len(lotr)):
    for b in range(len(data)):
        
#Create an if statement, where the authors are the same in both datasets and the metascore is larger in the big dataset
        if lotr.Author.iloc[a] == data.Author.iloc[b] and lotr.Metascore_w.iloc[a] < data.Metascore_w.iloc[b]:

#Create the variable inc_meta (absolute values)        
                inc_meta = data.Metascore_w.iloc[b] - lotr.Metascore_w.iloc[a] #to calculate the relative increase of metascore

#Store data from the data dataset in a variable called row    
                row = data[c_names].iloc[b]
    
#Add the row to the new dataset RecoLOTR    
                RecoLOTR = RecoLOTR.append(row)
    
#Add the data from the variable inc_meta in the empty list incLOTR    
                incLOTR.append(inc_meta)
    
#Print the metascores and the inc_meta variable to see if the values are correct 
#                print(data.Metascore_w.iloc[b], lotr.Metascore_w.iloc[a], inc_meta)


# In[88]:


#Add a new column 'Increased Metascore' and fill it with the values from the list incLOTR
RecoLOTR['Increased Metascore'] = incLOTR

#Add a new column with the Metascore of the original movie
RecoLOTR['Metascore LOTR3'] = RecoLOTR['Metascore_w'] - RecoLOTR['Increased Metascore'] 
RecoLOTR


# In[89]:


#Create a new dataframe and pick a random Author, to check if the Metascores are correct
controllotr = lotr.loc[lotr['Author'] == 'EssenceOfSugar']
controllotr


# In[95]:


##Sort Dataframe by increased metascore (descending)
RecoLOTR2 = RecoLOTR.sort_values(by=['Increased Metascore'], ascending=False)
RecoLOTR2


# In[96]:


#Save dataframe to csv
RecoLOTR2.to_csv('RecoMoviesLOTR.csv')

