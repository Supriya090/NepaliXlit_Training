1. Installation

    ```
        # install Indicnlp library
        !git clone https://github.com/anoopkunchukuttan/indic_nlp_library.git
        !git clone https://github.com/anoopkunchukuttan/indic_nlp_resources.git

        # Install the necessary libraries
        !pip3 install sacremoses pandas mock sacrebleu tensorboardX pyarrow indic-nlp-library xformers triton

        # Install fairseq from source

        !git clone https://github.com/pytorch/fairseq.git
        %cd fairseq

        !pip install --editable ./
        %cd ..
    ```

2. Make finetuning folder

    ```
        mkdir Finetuning
        cd Finetuning
    ```

3. Download pretrained folder

    ```
        !wget https://github.com/Supriya090/NepaliXlit/releases/download/v1.0/nepalixlit-en-ne.zip
        !unzip nepalixlit-en-ne.zip
    ```

4. Download the unigram probability dictionaries for reranking en-indic model

    ```
        !wget https://github.com/AI4Bharat/IndicXlit/releases/download/v1.0/word_prob_dicts.zip
    ```

5. Prepare the corpus

    ```
        mkdir corpus
    ```
    Add your data to the corpus, in the format shown in `Finetuning/corpus`

6. Binarize the corpus

    ```
        CUDA_VISIBLE_DEVICES="1" fairseq-preprocess \
            --trainpref corpus/train_ne --validpref corpus/valid_ne --testpref corpus/test_ne \
            --srcdict corpus-bin/dict.en.txt \
            --tgtdict corpus-bin/dict.ne.txt \
            --source-lang en --target-lang ne \
            --destdir corpus-bin
    ```

7. Add the supporting languages to lang_list.txt
    (Already given in the repo, so can skip the step)

8. Start training

    ```
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
    ```

9. Generate result
    ```
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
    ```

----

To run a new batch of samples

```
    bash interactive.sh ne 'source/source.txt' 5 5
    python3 generate_result_files_txt.py ne 1`
```

---

For evaluation, run

```
    lang_abr=ne
    python3 evaluate_result_with_rescore_option.py \
    -i output/translit_result_$lang_abr.xml \
    -t output/translit_test_$lang_abr.xml  \
    -o output/evaluation_details_$lang_abr.csv \
    --acc-matrix-output-file output/matrix_score_$lang_abr.txt \
    --correct-predicted-words-file  output/correct_predicted_words_$lang_abr.txt \
    --wrong-predicted-words-file  output/wrong_predicted_words_$lang_abr.txt
```

-----

### Evaluation Result

**NepaliXlit**

| Metrics | Score |
| ----------- | ----------- |
| ACC | 0.679054 | 
| Mean F-score | 0.941215 |
| MRR | 0.758164 | 
| MAP_red | 0.679054 |
| ACC@10 | 0.854730 | 
| CharACC | 0.918287 |