#!/bin/bash
sqlite-utils insert hbooks.db books popular-history-books.csv --csv --pk isbn_10 File
sqlite-utils insert hbooks.db books_tags books-tags.csv --csv File
sqlite-utils insert hbooks.db tags tags.csv --csv --pk pk_tag_id File
sqlite-utils transform hbooks.db tags --type tag_sort INTEGER
sqlite-utils insert hbooks.db cats cats.csv --csv --pk pk_cat_id File
sqlite-utils transform hbooks.db cats --type cat_sort INTEGER
sqlite-utils enable-fts hbooks.db books title author publisher --fts4 --tokenize porter
sqlite-utils transform hbooks.db books --type pages INTEGER
sqlite-utils convert hbooks.db books hb_publish_date 'r.parsedate(value, dayfirst=True)'
