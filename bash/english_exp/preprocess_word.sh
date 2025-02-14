####################
# Preprocess CLang8
####################

FAIRSEQ_DIR=../../src/src_syngec/fairseq-0.10.2/fairseq_cli
PROCESSED_DIR=../../preprocess/english_clang8_with_syntax_bart

WORKER_NUM=32
DICT_SIZE=32000
CoNLL_SUFFIX=word
CoNLL_SUFFIX_PROCESSED=word_np

# File path
TRAIN_SRC_FILE=../../../data/english_data/train_data/train.src
TRAIN_TGT_FILE=../../../data/english_data/train_data/train.tgt
VALID_SRC_FILE=../../../data/english_data/valid_data/valid.src
VALID_TGT_FILE=../../../data/english_data/valid_data/valid.tgt

# apply bpe
if [ ! -f $TRAIN_SRC_FILE".bart_bpe" ]; then
    echo "Apply BPE..."
    python ../../src/src_syngec/fairseq-0.10.2/examples/roberta/multiprocessing_bpe_encoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $TRAIN_SRC_FILE \
        --outputs $TRAIN_SRC_FILE".bart_bpe" \
        --workers 60 \
        --keep-empty
    python ../../src/src_syngec/fairseq-0.10.2/examples/roberta/multiprocessing_bpe_encoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $TRAIN_TGT_FILE \
        --outputs $TRAIN_TGT_FILE".bart_bpe" \
        --workers 60 \
        --keep-empty
    python ../../src/src_syngec/fairseq-0.10.2/examples/roberta/multiprocessing_bpe_encoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $VALID_SRC_FILE \
        --outputs $VALID_SRC_FILE".bart_bpe" \
        --workers 60 \
        --keep-empty
    python ../../src/src_syngec/fairseq-0.10.2/examples/roberta/multiprocessing_bpe_encoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $VALID_TGT_FILE \
        --outputs $VALID_TGT_FILE".bart_bpe" \
        --workers 60 \
        --keep-empty
fi

# Decode
if [ ! -f $TRAIN_SRC_FILE".bart_bpe.tok" ]; then
    python ../../utils/multiprocessing_bpe_decoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $TRAIN_SRC_FILE".bart_bpe" \
        --outputs $TRAIN_SRC_FILE".bart_bpe.tok" \
        --workers 60 \
        --keep-empty
    python ../../utils/multiprocessing_bpe_decoder.py \
        --encoder-json ../../pretrained_weights/encoder.json \
        --vocab-bpe ../../pretrained_weights/vocab.bpe \
        --inputs $VALID_SRC_FILE".bart_bpe" \
        --outputs $VALID_SRC_FILE".bart_bpe.tok" \
        --workers 60 \
        --keep-empty
fi

# Subword Align
#if [ ! -f $TRAIN_SRC_FILE".bart_swm" ]; then
 #   echo "Align subwords and words..."
#    python ../../utils/subword_align.py $TRAIN_SRC_FILE $TRAIN_SRC_FILE".bart_bpe.tok" $TRAIN_SRC_FILE".bart_swm"
 #   python ../../utils/subword_align.py $VALID_SRC_FILE $VALID_SRC_FILE".bart_bpe.tok" $VALID_SRC_FILE".bart_swm"
#fi

# fairseq preprocess
mkdir -p $PROCESSED_DIR
cp $TRAIN_SRC_FILE $PROCESSED_DIR/train.src
cp $TRAIN_SRC_FILE".bart_bpe" $PROCESSED_DIR/train.bpe.src
cp $TRAIN_TGT_FILE $PROCESSED_DIR/train.tgt
cp $TRAIN_TGT_FILE".bart_bpe" $PROCESSED_DIR/train.bpe.tgt
cp $VALID_SRC_FILE $PROCESSED_DIR/valid.src
cp $VALID_SRC_FILE".bart_bpe" $PROCESSED_DIR/valid.bpe.src
cp $VALID_TGT_FILE $PROCESSED_DIR/valid.tgt
cp $VALID_TGT_FILE".bart_bpe" $PROCESSED_DIR/valid.bpe.tgt

#cp $TRAIN_SRC_FILE".bart_swm" $PROCESSED_DIR/train.swm.src
#cp $VALID_SRC_FILE".bart_swm" $PROCESSED_DIR/valid.swm.src

# syntax specific
#python ../../utils/syntax_information_reprocess.py $TRAIN_SRC_FILE $CoNLL_SUFFIX conll bart
#python ../../utils/syntax_information_reprocess.py $TRAIN_SRC_FILE $CoNLL_SUFFIX probs bart
#python ../../utils/syntax_information_reprocess.py $VALID_SRC_FILE $CoNLL_SUFFIX conll bart
#python ../../utils/syntax_information_reprocess.py $VALID_SRC_FILE $CoNLL_SUFFIX probs bart

#cp $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}" $PROCESSED_DIR/train.conll.src
#cp $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}" $PROCESSED_DIR/valid.conll.src

#if [ ! -f $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.dpd" ]; then
#    echo "Calculate dependency distance..."
#    python ../../utils/calculate_dependency_distance.py $TRAIN_SRC_FILE".${CoNLL_SUFFIX}" $PROCESSED_DIR/train.swm.src $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.dpd"
#    python ../../utils/calculate_dependency_distance.py $VALID_SRC_FILE".${CoNLL_SUFFIX}" $PROCESSED_DIR/valid.swm.src $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.dpd"
#fi

#cp $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.dpd" $PROCESSED_DIR/train.dpd.src
#cp $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.dpd" $PROCESSED_DIR/valid.dpd.src

#cp $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.probs" $PROCESSED_DIR/train.probs.src
#cp $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.probs" $PROCESSED_DIR/valid.probs.src

echo "Preprocess..."
mkdir -p $PROCESSED_DIR/bin

python $FAIRSEQ_DIR/preprocess.py --source-lang src --target-lang tgt \
    --user-dir ../../src/src_syngec/syngec_model \
    --task syntax-enhanced-translation \
    --trainpref $PROCESSED_DIR/train.bpe \
    --validpref $PROCESSED_DIR/valid.bpe \
    --destdir $PROCESSED_DIR/bin \
    --workers $WORKER_NUM \
    --labeldict ../../data/dicts/syntax_label_gec.dict \
    --srcdict ../../pretrained_weights/dict.txt \
    --tgtdict ../../pretrained_weights/dict.txt

echo "Finished!"

