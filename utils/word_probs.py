import sys
import re

label_dict={}
label_file = open("../../utils/data/probs_vocab.txt",'r').readlines()
for line in label_file:
    line=line.split('\t')
    label_dict[line[0]] = line[1].replace('\n','')
    
   # 注意

 
#def contains_english_char(s):
 #  return bool(re.search("[a-zA-Z0-9]", s))
word_file = open(sys.argv[1],'r').readlines()
word_label = open(sys.argv[2],'w')
write_line=''
percent=[]
for  word in word_file:
    if word =='\n':
        #sum_num = sum(percent)
        word_label.write(write_line.strip(' ')+' 0'+'\n')
        write_line='' 
        percent=[]
        continue
    word = word.strip('\n').split('\t')
    rel = word[2]+':'+word[3]+':'+word[5].replace('\n','')
    if rel in label_dict:
        le= label_dict[rel]
    else:
        le = 0
    write_line= write_line+' '+str(le)

