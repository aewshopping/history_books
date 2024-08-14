sqlite-utils insert ./data_csv/data.db books popular-history-books.csv --csv --pk isbn_10
sqlite-utils insert ./data_csv/data.db books_tags books-tags.csv --csv
sqlite-utils insert ./data_csv/data.db tags tags.csv --csv --pk pk_tag_id
sqlite-utils insert ./data_csv/data.db cats cats.csv --csv --pk pk_cat_id
sqlite-utils transform ./data_csv/data.db tags --type tag_sort INTEGER
sqlite-utils transform ./data_csv/data.db cats --type cat_sort INTEGER
sqlite-utils transform ./data_csv/data.db books --type pages INTEGER
sqlite-utils enable-fts ./data_csv/data.db books title author publisher --fts4 --tokenize porter
sqlite-utils convert ./data_csv/data.db books hb_publish_date 'r.parsedate(value, dayfirst=True)'
