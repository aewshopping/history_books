#!/bin/bash
sqlite-utils insert ${{ github.workspace }}/data.db books popular-history-books.csv --csv File
