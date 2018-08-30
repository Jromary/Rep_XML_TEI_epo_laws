#!/usr/bin/env bash
for var in $(ls Ressources/article/)
do
	html2xhtml Ressources/article/$var -o Ressources/article_xhtml/$var
done

for var in $(ls Ressources/rule/)
do
	html2xhtml Ressources/rule/$var -o Ressources/rule_xhtml/$var
done

for var in $(ls Ressources/ma/)
do
	html2xhtml Ressources/ma/$var -o Ressources/ma_xhtml/$var
done