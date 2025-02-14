import sys

f1=open(sys.argv[1],'r',encoding='utf8')
f2=open(sys.argv[2],'r',encoding='utf8')
f3=open(sys.argv[3],'w',encoding='utf8')
srcs=f1.readlines()
tags=f2.readlines()
label_dict={}
di=open('../../data/dicts/syntax_label_gec.dict','r')
for idx,line in enumerate(di):
    label_dict[line.strip('\n')]=idx
length=len(label_dict)
id_list=[]
for id in tags:
    for i in id.split(' '):
        if i=='':
            continue
        id_list.append(i)
assert len(id_list)==len(srcs)
num=0
write_line = ''
for line,tag in zip(srcs,id_list):
    if line=='\n':
        write_line= write_line+ str(length+1)
        f3.write(write_line+'\n')
        write_line=''
        num+=1
        continue
    lis=line.split('\t')
    if tag == '1':
        write_line = write_line + str(label_dict['MASK']) + ' '
        continue
    if  lis[7] in  label_dict:
        label_id = str(label_dict[lis[7]])
        write_line  = write_line + label_id +' '
    else:
        write_line = write_line + str(label_dict['unk']) + ' '


