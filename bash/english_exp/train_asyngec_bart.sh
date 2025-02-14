####################
# Train Baseline
####################

SEED=2022
FAIRSEQ_CLI_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
MODEL_DIR_STAGE1=../../model/english_baseline/$SEED/stage1
MODEL_DIR_STAGE2=../../model/english_baseline/$SEED/stage2
MODEL_DIR_STAGE3=../../model/english_baseline/$SEED/stage3
PROCESSED_DIR_STAGE1=../../preprocess/english_data_1
PROCESSED_DIR_STAGE2=../../preprocess/english_data_2
PROCESSED_DIR_STAGE3=../../preprocess/english_data_3
FAIRSEQ_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq
BART_PATH=../../PLMs/bart-large-english-2/english.pt   
mkdir -p $MODEL_DIR_STAGE1

mkdir -p $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE1/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE1/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE1


CUDA_VISIBLE_DEVICES=0,1,2,3  python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE1/bin \
    --save-dir $MODEL_DIR_STAGE1 \
    --task translation \
    --arch bart_large \
    --restore-file  $BART_PATH \
    --max-tokens 4000 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 1 \
    --lr 3e-05 \
    --warmup-updates 2000 \
    --weight-decay 0.01 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 5 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --reset-lr-scheduler \
    --reset-optimizer \
    --reset-meters \
    --reset-dataloader \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 3 \
    --seed $SEED \

wait

mkdir -p $MODEL_DIR_STAGE2

mkdir -p $MODEL_DIR_STAGE2/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE2/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE2/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE2/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE2

# Transformer-base-setting stage 2

CUDA_VISIBLE_DEVICES=0,1,2,3 python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE2/bin \
    --save-dir $MODEL_DIR_STAGE2 \
    --arch bart_large \
    --finetune-from-model $MODEL_DIR_STAGE1/checkpoint_best.pt \
    --task translation \
    --max-tokens 4000 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --weight-decay 0.01 \
    --update-freq 1 \
    --lr 5e-06 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 5 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 3 \
    --seed $SEED  

wait

mkdir -p $MODEL_DIR_STAGE3

mkdir -p $MODEL_DIR_STAGE3/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE3/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE3/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE3/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE3

# Transformer-base-setting stage 3
CUDA_VISIBLE_DEVICES=0,1,2,3 python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE3/bin \
    --save-dir $MODEL_DIR_STAGE3 \
    --arch bart_large \
    --finetune-from-model $MODEL_DIR_STAGE2/checkpoint_best.pt \
    --task translation \
    --max-tokens 4000 \
    --optimizer adam \
    --layernorm-embedding \
    --weight-decay 0.01 \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 1 \
    --lr 3e-06 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 10 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 3 \
    --seed $SEED 

wait


####################
# Train SynGEC
####################

SEED=2022
FAIRSEQ_CLI_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq_cli
MODEL_DIR_STAGE1=../../model/english_asyngec/$SEED/stage1
MODEL_DIR_STAGE2=../../model/english_asyngec/$SEED/stage2
MODEL_DIR_STAGE3=../../model/english_asyngec/$SEED/stage3
MODEL_DIR_STAGE4=../../model/english_asyngec/$SEED/stage4

PROCESSED_DIR_STAGE1=../../preprocess/english_data_1
PROCESSED_DIR_STAGE2=../../preprocess/english_data_2
PROCESSED_DIR_STAGE3=../../preprocess/english_data_3
FAIRSEQ_PATH=../../src/src_asyngec/fairseq-0.10.2/fairseq
BART_PATH=../../model/english_baseline/$SEED/stage3/checkpoint_best.pt

mkdir -p $MODEL_DIR_STAGE1

mkdir -p $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE1/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE1/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE1/src

cp ./train_asyngec_bart.sh $MODEL_DIR_STAGE1

# Transformer-base-setting stage 1


CUDA_VISIBLE_DEVICES=2,3  python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE1/bin \
    --save-dir $MODEL_DIR_STAGE3 \
    --user-dir ../../src/src_asyngec/asyngec_model \
    --use-syntax \
    --only-gnn \
    --syntax-encoder GCN \
    --freeze-bart-parameters \
    --task syntax-enhanced-translation \
    --arch syntax_enhanced_bart_large \
    --restore-file $BART_PATH \
    --max-sentence-length 64 \
    --max-tokens  2048 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 8\
    --lr 1e-04 \
    --warmup-updates 2000 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.05 \
    --max-epoch 60 \
    --patience 8 \
    --log-format tqdm \
    --reset-lr-scheduler \
    --reset-optimizer \
    --reset-meters \
    --reset-dataloader \
    --fp16 \
    --adam-betas '(0.9,0.999)' \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 12 \
    --seed $SEED 

wait

CUDA_VISIBLE_DEVICES=2,3, nohup python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE2/bin \
    --save-dir $MODEL_DIR_STAGE3 \
    --user-dir ../../src/src_asyngec/asyngec_model \
    --use-syntax \
    --only-gnn \
    --syntax-encoder GCN \
    --freeze-bart-parameters \
    --task syntax-enhanced-translation \
    --arch syntax_enhanced_bart_large \
    --finetune-from-model $BART_PATH \
    --max-sentence-length 128 \
    --max-tokens 2048 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 4 \
    --lr 5e-05 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 10 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 10 \
    --seed $SEED 

wait




mkdir -p $MODEL_DIR_STAGE2

mkdir -p $MODEL_DIR_STAGE2/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE2/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE2/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE2/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE2

# Transformer-base-setting stage 2

CUDA_VISIBLE_DEVICES=0,1,2,3  python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE2/bin \
    --save-dir $MODEL_DIR_STAGE2 \
    --user-dir ../../src/src_asyngec/asyngec_model \
    --use-syntax \
    --only-gnn \
    --syntax-encoder GCN \
    --freeze-bart-parameters \
    --task syntax-enhanced-translation \
    --arch syntax_enhanced_bart_large \
    --finetune-from-model $MODEL_DIR_STAGE1/checkpoint_best.pt \
    --max-sentence-length 64 \
    --max-tokens 1580 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 4 \
    --lr 5e-05 \
    --weight-decay 0.01 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 10 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 5 \
    --seed $SEED 

wait

mkdir -p $MODEL_DIR_STAGE3

mkdir -p $MODEL_DIR_STAGE3/src

cp -r $FAIRSEQ_PATH $MODEL_DIR_STAGE3/src

cp -r $FAIRSEQ_CLI_PATH $MODEL_DIR_STAGE3/src

cp -r ../../src/src_asyngec/asyngec_model $MODEL_DIR_STAGE3/src

cp ./train_syngec_bart.sh $MODEL_DIR_STAGE3

# Transformer-base-setting stage 3

CUDA_VISIBLE_DEVICES=0,1,2,3  python -u $FAIRSEQ_CLI_PATH/train.py $PROCESSED_DIR_STAGE3/bin \
    --save-dir $MODEL_DIR_STAGE3 \
    --user-dir ../../src/src_asyngec/asyngec_model \
    --use-syntax \
    --only-gnn \
    --syntax-encoder GCN \
    --freeze-bart-parameters \
    --task syntax-enhanced-translation \
    --arch syntax_enhanced_bart_large \
    --finetune-from-model $MODEL_DIR_STAGE2/checkpoint_best.pt \
    --max-sentence-length 64 \
    --max-tokens 1580 \
    --optimizer adam \
    --layernorm-embedding \
    --share-all-embeddings \
    --share-decoder-input-output-embed \
    --update-freq 4 \
    --lr 5e-05 \
    --weight-decay 0.01 \
    -s src \
    -t tgt \
    --dropout 0.3 \
    --lr-scheduler polynomial_decay \
    --clip-norm 0.1 \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --max-epoch 60 \
    --patience 10 \
    --adam-betas '(0.9,0.999)' \
    --log-format tqdm \
    --fp16 \
    --skip-invalid-size-inputs-valid-test \
    --find-unused-parameters \
    --keep-last-epochs 5 \
    --seed $SEED 

wait

