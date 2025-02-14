import sys

conll=open(sys.argv[1],'r').readlines()
word=open('./eng_word_vocab.txt','w')
dep=open('./eng_pos_vocab','w')
cixing=open('./eng_cixing.txt','w')
word_s=set()
dep_s=set()
cixing_s=set()

for line in conll:
    if line =='\n':
        continue
    line=line.strip('\n')
    lis=line.split('\t')
    word_s.add(lis[1])
    cixing_s.add(lis[2]+":"+lis[3])
    dep_s.add(lis[5])
for w in word_s:
    word.write(w+'\n')
for d in dep_s:
    cixing.write(d+'\n')
for c in cixing_s:
    dep.write(c+'\n')

word.close()
dep.close()
cixing.close()


