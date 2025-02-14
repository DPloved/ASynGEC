####################
# Preprocess HSK+Lang8
####################

FAIRSEQ_DIR=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
PROCESSED_DIR=../../preprocess/chinese_baseline

WORKER_NUM=32
DICT_SIZE=32000
TRAIN_FILE=../../data/lang8+hsk/train_data/train
VALID_FILE=../../data/lang8+hsk/valid_data/dev


# File path
TRAIN_SRC_FILE=$TRAIN_FILE".src"
TRAIN_TGT_FILE=$TRAIN_FILE".tgt"
TRAIN_LABEL=$TRAIN_FILE".label"
VALID_SRC_FILE=$VALID_FILE".src"
VALID_TGT_FILE=$VALID_FILE".tgt"
VALID_LABEL=$VALID_FILE".label"
TRAIN_FILE_CONLL=$TRAIN_FILE."conll"
VALID_FILE_CONLL=$VALID_FILE."conll"
# apply char
if [ ! -f $TRAIN_SRC_FILE".char" ]; then
python ../../utils/segment_bert.py <$TRAIN_SRC_FILE >$TRAIN_SRC_FILE".char"
python ../../utils/segment_bert.py <$TRAIN_TGT_FILE >$TRAIN_TGT_FILE".char"
python ../../utils/segment_bert.py <$VALID_SRC_FILE >$VALID_SRC_FILE".char"
python ../../utils/segment_bert.py <$VALID_TGT_FILE >$VALID_TGT_FILE".char"
fi

if [ ! -f $TRAIN_FILE".LABEL" ]; then
#make detect tag
python ../../utils/preprocess_data.py -s $VALID_SRC_FILE".char" -t $VALID_TGT_FILE".char" -o $VALID_LABEL --worker_num 64
python ../../utils/preprocess_data.py -s $TRAIN_SRC_FILE".char" -t $TRAIN_TGT_FILE".char" -o $TRAIN_LABEL --worker_num 64
 
python ../../utils/make_tag.py <$TRAIN_LABEL >$TRAIN_FILE".tag"
python ../../utils/make_tag.py <$VALID_LABEL >$VALID_FILE".tag"
#make pinyin tag
fi
if [ ! -f $TRAIN_FILE".syn_label" ]; then 
python ../../utils/make_syn_label.py $TRAIN_FILE_CONLL  $TRAIN_FILE".tag" $TRAIN_FILE".label"
python ../../utils/make_syn_label.py $VALID_FILE_CONLL  $VALID_FILE".tag" $VALID_FILE".label" 

fi



# fairseq preprocess
mkdir -p $PROCESSED_DIR
cp $TRAIN_SRC_FILE $PROCESSED_DIR/train.src
cp $TRAIN_SRC_FILE".char" $PROCESSED_DIR/train.char.src
cp $TRAIN_TGT_FILE $PROCESSED_DIR/train.tgt
cp $TRAIN_TGT_FILE".char" $PROCESSED_DIR/train.char.tgt
cp $TRAIN_TGT_FILE".label" $PROCESSED_DIR/train.label

cp $VALID_SRC_FILE $PROCESSED_DIR/valid.src
cp $VALID_SRC_FILE".char" $PROCESSED_DIR/valid.char.src
cp $VALID_TGT_FILE $PROCESSED_DIR/valid.tgt
cp $VALID_TGT_FILE".char" $PROCESSED_DIR/valid.char.tgt
cp $VALID_TGT_FILE".label" $PROCESSED_DIR/valid.label





echo "Preprocess..."
mkdir -p $PROCESSED_DIR/bin

python $FAIRSEQ_DIR/preprocess.py --source-lang src --target-lang tgt \
       --user-dir ../../src/src_syngec/syngec_model \
       --task syntax-enhanced-translation \
       --trainpref $PROCESSED_DIR/train.char \
       --validpref $PROCESSED_DIR/valid.char \
       --destdir $PROCESSED_DIR/bin \
       --workers $WORKER_NUM \
       --srcdict ../../data/dicts/chinese_vocab.count.txt \
       --tgtdict ../../data/dicts/chinese_vocab.count.txt \

echo "Finished!"
