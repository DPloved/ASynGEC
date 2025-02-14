####################
# Train Baseline
####################

SEED=2025
FAIRSEQ_CLI_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
MODEL_DIR_STAGE1=../../model/chinese_bart_baseline/$SEED/asyngec_1
#MODEL_DIR_STAGE2=../../model/chinese_bart_baseline/$SEED/stage5
PROCESSED_DIR_STAGE1=../../preprocess/chinese_transformer/bin
FAIRSEQ_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq
PLM=../../plms/bart-large-chinese-1
mkdir -p $MODEL_DIR_STAGE1

mkdir -p $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE1/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE1/src
cp preprocess_word.sh  $MODEL_DIR_STAGE1/preprocess_word.sh
cp ./train_asyngec_bart.sh $MODEL_DIR_STAGE1

# Transformer-base-setting stage 1

CUDA_VISIBLE_DEVICES=0,1  python -u $FAIRSEQ_CLI_PATH/train.py ../../preprocess/chinese_transformer/bin \
   --save-dir $MODEL_DIR_STAGE1 \
   --user-dir ../../src/src_asyngec/asyngec_model \
   --task syntax-enhanced-translation \
   --arch syntax_enhanced_bart_large \
   --skip-invalid-size-inputs-valid-test \
   --max-tokens  8192 \
   --optimizer adam \
   --bart-model-file-from-transformers $PLM  \
   --max-source-positions 512 \
   --max-target-positions 512 \
   --lr 3e-05 \
   --warmup-updates 2000 \
   -s src \
   -t tgt \
   --clip-norm 1.0 \
   --lr-scheduler polynomial_decay \
   --criterion label_smoothed_cross_entropy \
   --label-smoothing 0.1 \
   --max-epoch 2 \
   --share-all-embeddings \
   --adam-betas '(0.9,0.999)' \
   --log-format tqdm \
   --find-unused-parameters \
   --keep-last-epochs 10 \
   --patience 0 \
   --seed $SEED \
   --fp16  \

wait


####################
# Train ASynGEC
####################

SEED=2025
FAIRSEQ_CLI_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
MODEL_DIR_STAGE1=../../model/chinese_bart_asyngec/$SEED/stage1
BART_PATH=../../model/chinese_bart_baseline/$SEED/asyngec_1/checkpoint_best.pt

mkdir -p $MODEL_DIR_STAGE1

mkdir -p $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE1/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE1/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE1

# Transformer-base-setting stage 1

CUDA_VISIBLE_DEVICES=1,2,  python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE1/ \
    --save-dir $MODEL_DIR_STAGE1 \
    --user-dir ../../src/src_asyngec/asyngec_model \
    --use-syntax \
    --only-gnn \
    --syntax-encoder GCN \
    --freeze-bart-parameters \
    --finetune-from-model $BART_PATH \
    --task syntax-enhanced-translation \
    --arch syntax_enhanced_bart_large \
    --skip-invalid-size-inputs-valid-test \
    --max-tokens 4096 \
    --optimizer adam \
    --max-source-positions 512 \
    --max-target-positions 512 \
    --max-sentence-length 128 \
    --lr 5e-04 \
    --warmup-updates 2000 \
    -s src \
    -t tgt \
    --fp16  \
    --lr-scheduler polynomial_decay \
    --clip-norm 1.0 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --share-all-embeddings \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --find-unused-parameters \
    --keep-last-epochs 10 \
    --patience 5 \
    --seed $SEED \



wait


