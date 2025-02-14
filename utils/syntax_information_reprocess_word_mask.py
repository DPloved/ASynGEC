from multiprocessing import Pool
import numpy as np
import pickle
import sys
import gc
from tqdm import tqdm
from fairseq.data import LabelDictionary


num_workers = 1
src_file = sys.argv[1]
conll_suffix = sys.argv[2]
mode = sys.argv[3]
structure = sys.argv[4]
tag_path = sys.argv[5]
tag_list = open(tag_path,'r').readlines()
input_prefix = f"{src_file}.{conll_suffix}"
if structure == "transformer":
    output_file = input_prefix + "_np"  # 注意
else:
    output_file = input_prefix + "_bart_np"  # 注意
input_file = f"{src_file}.{conll_suffix}"

label_file = "../../utils/data/cixing.txt"   # 注意
label_dict = LabelDictionary.load(label_file)
def create_sentence_syntax_graph_matrix(chunk,tag, append_eos=True):
   
    chunk = chunk.split("\n")
    seq_len = len(chunk)
    tag = tag.split(" ")[:-1]
    if append_eos:
        seq_len += 1
    assert len(tag)==seq_len-1
    
    incoming_matrix = np.ones((seq_len, seq_len))
    incoming_matrix *= label_dict.index("<nadj>")
      # outcoming矩阵可以通过转置得到
    for l,ta in zip(chunk,tag):
        infos = l.rstrip().split()
        child, father = int(infos[0]) - 1, int(infos[4]) - 1  # 该弧的孩子和父亲
        if father == -1:
            father = len(chunk)
        if ta=='1':
            rel="MASK"
        else: # EOS代替Root
            rel = infos[5]
        incoming_matrix[child,father] = label_dict.index(rel)
    return incoming_matrix


def use_swm_to_adjust_matrix(matrix, swm, append_eos=True):
    if append_eos:
        swm.append(matrix.shape[0]-1)
    new_matrix = np.zeros((len(swm), len(swm)))
    for i in range(len(swm)):
        for j in range(len(swm)):
            new_matrix[i,j] = matrix[swm[i],swm[j]]
    return new_matrix


def convert_list_to_nparray(matrix):
    return np.array(matrix)

def convert_probs_to_nparray(t):
    matrix, swm = t
    if isinstance(matrix, list):
        matrix = np.array(matrix)
    return use_swm_to_adjust_matrix(matrix, swm)


def convert_conll_to_nparray(t):
    conll_chunk,tag =t
    incoming_matrix = create_sentence_syntax_graph_matrix(conll_chunk,tag)
   # incoming_matrix = use_swm_to_adjust_matrix(incoming_matrix, swm)
    return incoming_matrix


def data_format_convert():
    with open(output_file, 'wb') as f_out:
        res = []
        with Pool(num_workers) as pool:
            if mode == "conll":
                print(input_file)
                with open(input_file, 'r') as f_in:
                    conll_chunks = [conll_chunk for conll_chunk in f_in.read().split("\n\n") if conll_chunk and conll_chunk != "\n"]
                    for mat in pool.imap(convert_conll_to_nparray, tqdm(zip(conll_chunks,tag_list)), chunksize=256):
                        res.append(mat)
        pickle.dump(res, f_out)


if __name__ == "__main__":
    data_format_convert()
