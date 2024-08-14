#!/bin/bash
sqlite-utils create-database data.db
sqlite-utils insert data.db books popular-history-books.csv --csv File
