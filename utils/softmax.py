import torch
import numpy as np
import sys
import pickle
f1=open(sys.argv[1],'rb')
print('已读取')
prob_list=pickle.load(f1)
print('已加载')
new_lis=[]
for line in prob_list:
    arr_without_inf = line[~np.isinf(line)]
    min_val = np.min(arr_without_inf)
    line =line-min_val
    max_val = np.max(line)+1
    line = line/ max_val
    line = np.where(np.isinf(line), 0, line)
    # line=torch.tensor(line)
    # line = torch.softmax(line, dim=-1)
    new_lis.append(line)

with open(sys.argv[2],'wb') as o:
    pickle.dump(new_lis,o)
