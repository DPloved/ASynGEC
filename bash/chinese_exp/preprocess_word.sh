####################
# Preprocess HSK+Lang8
####################

FAIRSEQ_DIR=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
PROCESSED_DIR=../../preprocess/chinese_transformer
WORKER_NUM=32
DICT_SIZE=32000
CoNLL_SUFFIX=word
CoNLL_SUFFIX_PROCESSED=word_np
# File path
TRAIN_SRC_FILE=../../data/zh_data/lang8+hsk/train_data/train.src
TRAIN_TGT_FILE=../../data/zh_data/lang8+hsk/train_data/train.tgt
VALID_SRC_FILE=../../data/zh_data/MuCGEC/dev.src
VALID_TGT_FILE=../../data/zh_data/MuCGEC/dev.tgt

TRAIN_FILE=../../data/zh_data/lang8+hsk/train_data/train
VALID_FILE=../../data/zh_data/MuCGEC/dev
# apply char
if [ ! -f $TRAIN_SRC_FILE".char" ]; then
    python ../../utils/segment_bert.py <$TRAIN_SRC_FILE >$TRAIN_SRC_FILE".char"
    python ../../utils/segment_bert.py <$TRAIN_TGT_FILE >$TRAIN_TGT_FILE".char"
    python ../../utils/segment_bert.py <$VALID_SRC_FILE >$VALID_SRC_FILE".char"
    python ../../utils/segment_bert.py <$VALID_TGT_FILE >$VALID_TGT_FILE".char"
fi



# fairseq preprocess
mkdir -p $PROCESSED_DIR
cp $TRAIN_SRC_FILE $PROCESSED_DIR/train.src
cp $TRAIN_SRC_FILE".char" $PROCESSED_DIR/train.char.src
cp $TRAIN_TGT_FILE $PROCESSED_DIR/train.tgt
cp $TRAIN_TGT_FILE".char" $PROCESSED_DIR/train.char.tgt
cp $VALID_SRC_FILE $PROCESSED_DIR/valid.src
cp $VALID_SRC_FILE".char" $PROCESSED_DIR/valid.char.src
cp $VALID_TGT_FILE $PROCESSED_DIR/valid.tgt
cp $VALID_TGT_FILE".char" $PROCESSED_DIR/valid.char.tgt

echo "word_information_extract..."
python ../../utils/word_pos_preprocess.py $TRAIN_SRC_FILE".word" $TRAIN_SRC_FILE".tag" 
python ../../utils/word_pos_preprocess.py $VALID_SRC_FILE".word" $VALID_SRC_FILE".tag" 


echo "syntax_information_extract..."
python ../../utils/syntax_information_reprocess_word.py $TRAIN_SRC_FILE $CoNLL_SUFFIX conll transformer  
#python ../../utils/softmax.py  
python ../../utils/syntax_information_reprocess_word.py $TRAIN_SRC_FILE $CoNLL_SUFFIX probs transformer




cp $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}" $PROCESSED_DIR/train.conll.src
cp $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}" $PROCESSED_DIR/valid.conll.src
cp $TRAIN_SRC_FILE".tag"  $PROCESSED_DIR/train.tag
cp $VALID_SRC_FILE".tag"  $PROCESSED_DIR/valid.tag
cp $TRAIN_SRC_FILE".probs"  $PROCESSED_DIR/train.probs
cp $VALID_SRC_FILE".probs"  $PROCESSED_DIR/valid.probs






cp $TRAIN_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.probs" $PROCESSED_DIR/train.probs.src
cp $VALID_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.probs" $PROCESSED_DIR/valid.probs.src

echo "Preprocess..."
mkdir -p $PROCESSED_DIR/word

python $FAIRSEQ_DIR/preprocess_word.py --source-lang src --target-lang tgt \
       --user-dir ../../src/src_asyngec/asyngec_model \
       --task syntax-enhanced-translation \
       --trainpref $PROCESSED_DIR/train.char \
       --validpref $PROCESSED_DIR/valid.char \
       --destdir $PROCESSED_DIR/word \
       --workers $WORKER_NUM \
       --labeldict ../../utils/data/cixing.txt  \
       --conll-suffix conll \
       --probs-suffix probs \
       --srcdict ../../data/dicts/chinese_vocab.count.txt \
       --tgtdict ../../data/dicts/chinese_vocab.count.txt

echo "Finished!"
