CUDA_VISIBLE_DEVICES="1" fairseq-preprocess \
   --trainpref corpus/train_ne --validpref corpus/valid_ne --testpref corpus/test_ne \
   --srcdict corpus-bin/dict.en.txt \
   --tgtdict corpus-bin/dict.ne.txt \
   --source-lang en --target-lang ne \
   --destdir corpus-bin

CUDA_VISIBLE_DEVICES="1"  fairseq-train corpus-bin \
    --save-dir transformer \
    --arch transformer --layernorm-embedding \
    --task translation_multi_simple_epoch \
    --sampling-method "temperature" \
    --sampling-temperature 1.5 \
    --encoder-langtok "tgt" \
    --lang-dict lang_list.txt \
    --lang-pairs en-ne\
    --decoder-normalize-before --encoder-normalize-before \
    --activation-fn gelu --adam-betas "(0.9, 0.98)"  \
    --batch-size 16 \
    --decoder-attention-heads 4 --decoder-embed-dim 256 --decoder-ffn-embed-dim 1024 --decoder-layers 6 \
    --dropout 0.5 \
    --encoder-attention-heads 4 --encoder-embed-dim 256 --encoder-ffn-embed-dim 1024 --encoder-layers 6 \
    --lr 0.001 --lr-scheduler inverse_sqrt \
    --max-epoch 3 \
    --optimizer adam  \
    --num-workers 0 \
    --warmup-init-lr 0 --warmup-updates 4000 \
    --keep-last-epochs 2 \
    --patience 5 \
    --restore-file transformer/checkpoint_best.pt \
    --reset-lr-scheduler \
    --reset-meters \
    --reset-dataloader \
    --reset-optimizer

CUDA_VISIBLE_DEVICES="1" fairseq-generate corpus-bin \
  --path transformer/checkpoint_best.pt \
  --task translation_multi_simple_epoch \
  --gen-subset test \
  --beam 4 \
  --nbest 4 \
  --source-lang en \
  --target-lang ne \
  --batch-size 16 \
  --encoder-langtok "tgt" \
  --lang-dict lang_list.txt \
  --num-workers 0 \
  --lang-pairs en-ne  > output/en_ne.txt

lang_abr=ne
python3 evaluate_result_with_rescore_option.py \
-i output/translit_result_$lang_abr.xml \
-t output/translit_test_$lang_abr.xml  \
-o output/evaluation_details_$lang_abr.csv \
--acc-matrix-output-file output/matrix_score_$lang_abr.txt \
--correct-predicted-words-file  output/correct_predicted_words_$lang_abr.txt \
--wrong-predicted-words-file  output/wrong_predicted_words_$lang_abr.txt


# To run a new batch of samples

# bash interactive.sh ne 'source/source.txt' 5 5
# python3 generate_result_files_txt.py ne 1