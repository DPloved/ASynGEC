# ASynGEC
ASynGEC: Adaptive Syntax-Enhanced Grammatical Error Correction


# Overview
We propose an approach named **ASynGEC** to incorporate adapted dependency syntax knowledge into GEC models. The key idea is adjusting vanilla
dependency parsers to accommodate ungrammatical sentences. To achieve this goal, we introduce Part-of-Speech (POS) information to guide the encoding of syntactic features. Meanwhile, we replace the character level dependency tree with the original word-level dependency tree, as the word-level
tree contains more detailed information.


# How to Install

You can use the following commands to install the environment for ASynGEC:

```
conda create -n asyngec python==3.8
conda activate asyngec
pip install -r requirements.txt
cd src/src_asyngec/fairseq-0.10.2
pip install --editable ./
```

The ASynGEC model for GEC is based on [fairseq-0.10.2](https://github.com/facebookresearch/fairseq/tree/v0.10.2).



# How to Use

## Description of Codes
```
|-- bash  # Some scripts to reproduce our results
|   |-- chinese_exp
|   `-- english_exp
|-- data  # Data files (mainly parallel sentence files)
|   |-- bea19_dev
|   |-- bea19_test
|   |-- clang8_train
|   |-- conll14_test
|   |-- dicts
|   |-- error_coded_train
|   |-- hsk+lang8_train
|   |-- hsk_train
|   |-- mucgec_dev
|   |-- mucgec_test
|   `-- wi_locness_train
|-- model  # Model checkpoints for GOPar and SynGEC
|   `-- asyngec
|-- preprocess  # Preprocessed binary files for fairseq training
|-- pretrained_weights  # Pretrained language models, e.g., BART
|-- src  # Main codes of our GOPar and SynGEC models
|   |-- src_asyngec
|       |-- fairseq-0.10.2  # Our modified Fairseq. Specifically, we modify their trainer, modules, datasets, etc.
|       `-- asyngec_model  # Main model files for SynGEC
`-- utils  # Some important tools, including tree projection codes
```

# How to Train
If you want to train new models using your own dataset, please follow the instructions in `./bash/*_exp`:

+ `preprocess_asyngec_*.sh`: preprocess data for training GEC models;

+ `train_asyngec_*.sh`: train baseline & ASynGEC models;

+ `generate_asyngec_*.sh`: generate results (CoNLL14 and BEA19 for English, NLPCC18 and MuCGEC for Chinese);

