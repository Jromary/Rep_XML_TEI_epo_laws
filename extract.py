from html.parser import HTMLParser
import urllib.request
import re
import subprocess
import os

# template link to same domain
REGEX = re.compile('"(.)*\.html"')

# list of urls done and still to do
URLTODO = []
URLDONE = []


class Parser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        # if tag "a" found
        if tag == "a":
            # extract link from href attribute
            for attr in attrs:
                # remove all java and link to another domain
                if attr[0] == "href" and (re.match("java", attr[1]) is None) \
                        and (re.match("/", attr[1]) is None) \
                        and (re.match("http", attr[1]) is None) \
                        and (re.match("\.", attr[1]) is None) \
                        and (re.match("#", attr[1]) is None):
                    # potentielement une note de bas de page avec le "#"

                    # add, if not done, the link to the to do list
                    if attr[1] not in URLDONE:
                        # print(attr[1])
                        URLTODO.append(attr[1])


def extract_link(url):
    # add url to the done list and remove it from the to do
    print(url)
    if url in URLDONE:
        return
    URLDONE.append(url)
    if url in URLTODO:
        URLTODO.remove(url)
    # add domain before link
    # if re.match("http", url) is None:
    #    new_url = "https://www.epo.org/law-practice/legal-texts/html/epc/2016/e/" + str(new_url)

    try:
        new_url = "https://www.epo.org/law-practice/legal-texts/html/epc/2016/e/" + str(url)
        urlopener = urllib.request.urlopen(new_url)
    except:
        print("no page found at : " + url)
        return

    if urlopener.getcode() != 200:
        print("Erreur de connection a la page : " + url)
        return
    # parsing extracted data
    data = urlopener.read().decode("utf-8")
    parser = Parser()
    parser.feed(data)

    with open("Ressources/" + url, "w") as file:
        file.write(data)

    for link in URLTODO:
        extract_link(link)


def move():
    moveArticle()
    moveIndex()
    moveRule()
    moveMa()


def moveMa():
    commande = 'mv Ressources/ma2a.html Ressources/ma3.html Ressources/ma4.html Ressources/ma5.html Ressources/ma5a.html Ressources/ma5b.html Ressources/ma5c.html Ressources/ma/'
    os.system(commande)
    pass


def moveArticle():
    commande = 'mv Ressources/ar????.html Ressources/ar???.html Ressources/ar??.html Ressources/ar?.html Ressources/article/'
    os.system(commande)
    pass


def moveIndex():
    commande = 'mv Ressources/a[^0-9]?.html Ressources/a[^0-9]??.html Ressources/a[^0-9]???.html Ressources/a[^0-9]????.html Ressources/a[^0-9]?????.html Ressources/a[^0-9]??????.html Ressources/a[^0-9]???????.html Ressources/a[^0-9]????????.html Ressources/index/'
    os.system(commande)
    commande = 'mv Ressources/r[^0-9]?.html Ressources/r[^0-9]??.html Ressources/r[^0-9]???.html Ressources/r[^0-9]????.html Ressources/r[^0-9]?????.html Ressources/r[^0-9]??????.html Ressources/r[^0-9]???????.html Ressources/r[^0-9]????????.html Ressources/index/'
    os.system(commande)
    pass

def moveRule():
    commande = 'mv Ressources/r?.html Ressources/r??.html Ressources/r???.html Ressources/r????.html Ressources/rule/'
    os.system(commande)
    pass

def html2xhtml():
    commande = 'bash scripts/transfoh2x.sh'
    os.system(commande)
    pass


def article():
    tp = True
    rg = True

    # apply template
    if tp:
        print("Starting transformation from xhtml to xml")
        commande = 'java -jar scripts/saxon9ee.jar scripts/linkArticle.xsl scripts/linkArticle.xsl > articleOutput.xml'
        os.system(commande)
        print("transformation from xhtml to xml Done")

    # regenerate html
    if rg:
        print("Starting generation of new xhtml")
        commande = 'java -jar scripts/saxon9ee.jar articleOutput.xml scripts/recreateArticle.xsl'
        os.system(commande)
        print("generation of new xhtml Done")


def regulation():
    tp = True
    rg = True

    # apply template
    if tp:
        print("Starting transformation from xhtml to xml")
        commande = 'java -jar scripts/saxon9ee.jar scripts/linkRule.xsl scripts/linkRule.xsl > ruleOutput.xml'
        os.system(commande)
        print("transformation from xhtml to xml Done")

    # regenerate html
    if rg:
        print("Starting generation of new xhtml")
        commande = 'java -jar scripts/saxon9ee.jar ruleOutput.xml scripts/recreateRule.xsl'
        os.system(commande)
        print("generation of new xhtml Done")


def others():
    tp = True
    rg = False

    # apply template
    if tp:
        print("Starting transformation from xhtml to xml")
        commande = 'java -jar scripts/saxon9ee.jar Ressources/ma_xhtml/ma2a.html scripts/transfo.xsl > ma2aOutput.xml'
        os.system(commande)
        print("transformation from xhtml to xml Done")

    # regenerate html
    if rg:
        pass


def main():
    dl = False
    mv = False
    hx = False

    onArticle = True
    onRule = True
    onOther = False

    # DL all article and more
    if dl:
        print("Starting DL")
        extract_link("ma1.html")
        print("DL Done")

    # move all article
    if mv:
        print("Starting move")
        move()
        print("move Done")

    # html to xhtml
    if hx:
        print("Starting html -> xhtml")
        html2xhtml()
        print("html -> xhtml Done")

    if onArticle:
        print("<---- Article ---->")
        article()
    if onRule:
        print("<---- Rule ---->")
        regulation()
    if onOther:
        print("<---- Other ---->")
        others()


if __name__ == "__main__":
    main()
