import sys
from fairseq.data import LabelDictionary
pos_file = '../../utils/data/eng_pos_vocab'
word_dict= LabelDictionary.load(pos_file)

word_file = open(sys.argv[1],'r').readlines()
word_label = open(sys.argv[2],'w')
write_line=''
for  word in word_file:
    if word =='\n':
        word_label.write(write_line.strip(' ')+' 66'+'\n')
        write_line=''
        continue
    word = word.strip('\n').split('\t')
    rel = word[2]+':'+word[3]
    ids = word_dict.index(rel)
    write_line = write_line + ' ' +str(ids)
    

