#!/usr/bin/python
import sys
import os.path
import csv
import re

if len(sys.argv) < 2:
   print "Specify path to file"
   sys.exit()

path_to_tsv = sys.argv[1]

if not os.path.isfile(path_to_tsv):
   print path_to_tsv + " is no file"


tsv  = open(path_to_tsv)
html = open(os.path.basename(path_to_tsv) + ".html", 'w')
html.write('<html><head><title>' + os.path.basename(path_to_tsv) + '</title></head><body>')

re_company_name = re.compile(r'<F>(.*?)<E>(.*)')
re_company_nr   = re.compile(r'(.*?)<L>(.*?)<E>(.*)')
re_where        = re.compile(r'<(S|5)>(.*?)<E>')        # Sitz neu: <5>Ortname<E>
re_rechtsform   = re.compile(r'<Q>(.*?)<E>')
re_tags         = re.compile(r'<.>')

for line in csv.reader(tsv, delimiter="\t"):
    # print line[0]
    text = line[22]
    
    # text = text.replace('<F>',  '<h1>', 1)
    # text = text.replace('<E>', '</h1>', 1)

    m = re_where.search(text)
    where = m.group(2)

    m = re_rechtsform.search(text)
    if m:
       rechtsform = m.group(1)
    else:
       rechtsform = ''

    m = re_company_name.search(text)
    company_name = m.group(1)
    text         = m.group(2)

    m = re_company_nr.match(text)
    company_where = m.group(1)
    company_nr    = m.group(2)
    text          = m.group(3)

    text = re_tags.sub('', text)

    html.write('<h1>' + company_name + '</h1>')
    html.write('<b>' + where + '</b> ' + rechtsform + '<p>')
    html.write(text + '<br>')
    html.write('<code>' + company_nr + '</code>')
    html.write("<hr>\n")


html.write('</body></html>')
