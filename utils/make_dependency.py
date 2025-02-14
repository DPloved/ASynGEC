import stanza
from tqdm import tqdm
import sys
import numpy as np
import pickle
nlp = stanza.Pipeline('zh',processors="depparse,tokenize,lemma,pos")

f1 = open(sys.argv[1], 'r').readlines()
f2 = open(sys.argv[2], 'w')
arcs=[]
for line in tqdm(f1):
    line = line.replace('\n', '')
    doc ,arc = nlp(line)
    arcs.append(arc[0])
    sentences = doc.sentences
    for sens in sentences:
        for sen in sens.words:
            id = sen.id
            text = sen.text
            upos = sen.upos
            xpos = sen.xpos
            head = sen.head
            deprel = sen.deprel
            f2.write(str(id) + '\t' + text + '\t' + upos + '\t' + xpos + '\t' + str(head) + '\t' + deprel + '\n')
    f2.write('\n')
    #for arc in arcs:
with  open(sys.argv[3],'wb') as o:
    pickle.dump(arcs,o)
