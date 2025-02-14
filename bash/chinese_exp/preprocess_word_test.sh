FAIRSEQ_DIR=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
PROCESSED_DIR=../../preprocess/chinese_transformer-test/

WORKER_NUM=32
DICT_SIZE=32000
CoNLL_SUFFIX=word
CoNLL_SUFFIX_PROCESSED=word_np

# File path
TEST_SRC_FILE=../../data/zh_data/test-data/test.src



python ../../utils/segment_bert.py <$TEST_SRC_FILE >$TEST_SRC_FILE".char"



# fairseq preprocess
mkdir -p $PROCESSED_DIR
cp $TEST_SRC_FILE $PROCESSED_DIR/test.src
cp $TEST_SRC_FILE".char" $PROCESSED_DIR/test.char.src



python ../../utils/word_pos_preprocess.py $TEST_SRC_FILE".word" $TEST_SRC_FILE".tag"
python ../../utils/syntax_information_reprocess_word.py $TEST_SRC_FILE $CoNLL_SUFFIX conll transformer  
python ../../utils/softmax.py $TEST_SRC_FILE".word.probs_un" $TEST_SRC_FILE".word.probs"
python ../../utils/syntax_information_reprocess_word.py $TEST_SRC_FILE $CoNLL_SUFFIX probs transformer

cp $TEST_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}" $PROCESSED_DIR/test.conll.src
cp $TEST_SRC_FILE".tag"  $PROCESSED_DIR/test.tag
cp $TEST_SRC_FILE".${CoNLL_SUFFIX_PROCESSED}.probs" $PROCESSED_DIR/test.probs.src




echo "Preprocess..."
mkdir -p $PROCESSED_DIR/bin

python $FAIRSEQ_DIR/preprocess_word.py --source-lang src --target-lang tgt \
       --user-dir ../../src/src_asyngec/asyngec_model \
       --task syntax-enhanced-translation \
       --only-source \
       --testpref $PROCESSED_DIR/test.char \
       --destdir $PROCESSED_DIR/bin \
       --workers $WORKER_NUM \
       --conll-suffix conll \
       --probs-suffix probs \
       --labeldict ../../utils/data/cixing.txt  \
       --srcdict ../../data/dicts/chinese_vocab.count.txt \
       --tgtdict ../../data/dicts/chinese_vocab.count.txt

echo "Finished!"
