#!/bin/bash
# -*- coding: utf-8 -*-

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data=$base/data/$tgt-$src/

# change into base directory to ensure paths are valid
cd $base

# create preprocessed directory
mkdir -p $data/preprocessed/

# normalize and tokenize raw data
cat $data/raw/train.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q > $data/preprocessed/train.$src.p
cat $data/raw/train.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q > $data/preprocessed/train.$tgt.p

# train truecase models
perl moses_scripts/train-truecaser.perl --model $data/preprocessed/tm.$src --corpus $data/preprocessed/train.$src.p
perl moses_scripts/train-truecaser.perl --model $data/preprocessed/tm.$tgt --corpus $data/preprocessed/train.$tgt.p

# apply truecase models to splits
cat $data/preprocessed/train.$src.p | perl moses_scripts/truecase.perl --model $data/preprocessed/tm.$src > $data/preprocessed/train.$src
cat $data/preprocessed/train.$tgt.p | perl moses_scripts/truecase.perl --model $data/preprocessed/tm.$tgt > $data/preprocessed/train.$tgt

# Train BPE on concatenated source and target data (we use 10,000 merge operations here; adjust as needed)
cat $data/preprocessed/train.$src $data/preprocessed/train.$tgt | subword-nmt learn-bpe -s 10000 > $data/preprocessed/bpe.codes

# Apply BPE to each data split (train, valid, test, tiny_train)
for split in train valid test tiny_train; do
    subword-nmt apply-bpe -c $data/preprocessed/bpe.codes < $data/preprocessed/$split.$src > $data/preprocessed/$split.bpe.$src
    subword-nmt apply-bpe -c $data/preprocessed/bpe.codes < $data/preprocessed/$split.$tgt > $data/preprocessed/$split.bpe.$tgt
done

# Remove temporary files
rm $data/preprocessed/train.$src.p
rm $data/preprocessed/train.$tgt.p

# Create a new directory for prepared BPE data
mkdir -p $data/prepared_BPE

# Preprocess BPE-encoded files for model training into prepared_BPE
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/prepared_BPE/ --train-prefix $data/preprocessed/train.bpe --valid-prefix $data/preprocessed/valid.bpe --test-prefix $data/preprocessed/test.bpe --tiny-train-prefix $data/preprocessed/tiny_train.bpe --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

echo "done!"
