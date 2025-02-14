from multiprocessing import Pool
import numpy as np
import pickle
import sys
import gc
from tqdm import tqdm
from fairseq.data import LabelDictionary

num_workers = 64
src_file = sys.argv[1]
conll_suffix = sys.argv[2]
mode = sys.argv[3]
structure = sys.argv[4]


input_prefix = f"{src_file}.{conll_suffix}"

if structure == "transformer":
    output_prefix = input_prefix + "_np"  # 注意
else:
    output_prefix = input_prefix + "_bart_np"  # 注意
input_file = f"{src_file}.{conll_suffix}"

if mode in ["dpd", "probs"]:  # 需要subword对齐的
    output_file = output_prefix + f".{mode}"
else:
    output_file = output_prefix


length_list=open(input_file+'.len','r').readlines()
label_file = "../../utils/data/cixing.txt"   # 注意
label_dict = LabelDictionary.load(label_file)
def create_sentence_syntax_graph_matrix(chunk, append_eos=True):
    chunk = chunk.split("\n")
    seq_len = len(chunk)
    if append_eos:
        seq_len += 1
    incoming_matrix = np.ones((seq_len, seq_len))
    incoming_matrix *= label_dict.index("<nadj>")
      # outcoming矩阵可以通过转置得到
    for l in chunk:
        infos = l.rstrip().split()
        child, father = int(infos[0]) - 1, int(infos[4]) - 1  # 该弧的孩子和父亲
        if father == -1:
            father = len(chunk) # EOS代替Root
        rel = infos[5]
        incoming_matrix[child,father] = label_dict.index(rel)
    return incoming_matrix

def use_swm_to_adjust_matrix(matrix,leng,append_eos=True):
    if matrix.shape[0]>=2:
        leng=leng.split(',')
        sum_leng=sum(int(le) for le in leng)
        new_matrix = np.ones((sum_leng+1, sum_leng+1))
        new_matrix = new_matrix * 0.1
        start_row =0
        start_col= 0
        for tupl in zip(matrix,leng):
            ma,length = tupl
            length=int(length)
            mat = np.array([m[:length] for m in  ma[:length]])
            n = mat.shape[0]
            new_matrix[start_row:start_row + n, start_col:start_col + n] = mat
            start_row = n + start_row
            start_col = n + start_col
    else:
        length=matrix.shape[1]
        new_matrix = np.ones((length, length))
        new_matrix = new_matrix * 0.1
        new_matrix[:length-1,:length-1] = np.array([m[:length-1] for m in  matrix[0][:length-1]])
    return new_matrix

def convert_list_to_nparray(matrix):
    return np.array(matrix)

def convert_probs_to_nparray(t):
    matrix ,leng = t
    leng = leng.replace('\n','')
    if isinstance(matrix, list):
        matrix = np.array(matrix)
    return use_swm_to_adjust_matrix(matrix,leng)


def convert_conll_to_nparray(t):
    conll_chunk =t
    incoming_matrix = create_sentence_syntax_graph_matrix(conll_chunk)
   # incoming_matrix = use_swm_to_adjust_matrix(incoming_matrix, swm)
    return incoming_matrix


def data_format_convert():
    with open(output_file, 'wb') as f_out:
        res = []
        with Pool(64) as pool:
            if mode == "conll":
                print(input_file)
                with open(input_file, 'r') as f_in:
                    conll_chunks = [conll_chunk for conll_chunk in f_in.read().split("\n\n") if conll_chunk and conll_chunk != "\n"]
                    print(len(conll_chunks))
                    for mat in pool.imap(convert_conll_to_nparray, tqdm(conll_chunks), chunksize=256):
                        res.append(mat)
            elif mode == "probs":
                with open(input_file+".probs", 'rb') as f_in:
                    print(input_file+".probs")
                    gc.disable()
                    arr_list = pickle.load(f_in)
                    gc.enable()
                    for mat in pool.imap(convert_probs_to_nparray, zip(arr_list,length_list), chunksize=256):
                        res.append(mat)



        pickle.dump(res, f_out)


if __name__ == "__main__":
    data_format_convert()
