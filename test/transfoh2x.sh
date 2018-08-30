#!/usr/bin/env bash
for var in $(ls article/)
do
	html2xhtml article/$var -o article_Xhtml/$var
done