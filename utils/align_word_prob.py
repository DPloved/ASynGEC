import sys
word=open(sys.argv[1],'r',encoding='utf8')
length =open(sys.argv[2],'w')

leng_lis=''
current_num=0
flag=0

for line in word:
    if line=='\n':

        leng_lis=leng_lis+","+str(flag)
        len_lis = leng_lis.strip(',')
        le=len_lis.split(',')
        sum_length=0
        length.write(len_lis+'\n')
        leng_lis=''
        flag=0
        current_num=0

        continue
    lis=line.split('\t')
    if current_num>int(lis[0]):
        leng_lis=leng_lis+','+str(flag)
        current_num = int(lis[0])
        flag=1
    else:
        current_num=int(lis[0])
        flag+=1

