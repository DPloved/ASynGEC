import sys


srcs=open(sys.argv[1],'r').readlines()
preds=open(sys.argv[2],'r').readlines()
outs=open(sys.argv[3],'w')
num=0
idx=0
sent=[]
se=[]
for pred in preds:
   if "D-" in pred:
       sent.append(pred)
for line in sent:
    line= line.split('\t')
    curr_id = "D-"+str(num)
    if curr_id != line[0]:
        outs.write(srcs[num]) 
        outs.write(line[2])

        num+=1
    else:
        outs.write(line[2])
    num+=1
   
  
