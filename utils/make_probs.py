import sys
from fairseq.data import LabelDictionary
import math
conll=open(sys.argv[1],'r').readlines()


import numpy as np
word=open('../../utils/data/probs_vocab.txt','w')
prob_dict={}
data=[]
for line in conll:
    if line =='\n':
        continue
    line=line.strip('\n')
    lis=line.split('\t')
    key=lis[2]+":"+lis[3]+":"+lis[5]
    if key in prob_dict:
        num=prob_dict[key]+1
        prob_dict[key]=num
        
    else:
        prob_dict[key]=1
for key,item in prob_dict.items():
    data.append(item)
sort_list= sorted(data)
#mean_val = np.mean(data)
#std_val = np.std(data)

inter_num = 1/len(sort_list)
probs_list = [i* inter_num  for i in range(len(sort_list))]
for key,value in prob_dict.items():
#    num =(value-mean_val)/std_val 
 #   if num < 0:
  #      num= num * -0.1
  #  else:
   #     num = math.sqrt(num)
    index = sort_list.index(value)
    probs = probs_list[index]
    write_line = key+'\t'+str(probs)
    word.write(write_line+'\n')

