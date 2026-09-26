"""Build the Section 6 guide using the established OOP guide's PDF styles.

Requires ReportLab and the Windows Calibri/Consolas fonts. Run from any folder.
Intermediate navigation data stays under ignored output/section-6-randomization.
"""
from pathlib import Path
import re
import html
import json
from urllib.parse import quote, unquote

from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (BaseDocTemplate, PageTemplate, Frame, Paragraph,
    Spacer, PageBreak, CondPageBreak, Table, TableStyle, Flowable, KeepTogether)
from reportlab.platypus.tableofcontents import TableOfContents

ROOT = Path(__file__).resolve().parents[1]
REV = ROOT / 'SV Basics' / 'Revision'
SOURCE = REV / 'Section-6-Randomization.md'
OUTPUT = REV / 'Section-6-Randomization.pdf'
WORK = ROOT / 'output' / 'section-6-randomization'
NAVY = colors.HexColor('#002060')
BLUE = colors.HexColor('#0563C1')
INK = colors.HexColor('#202C3A')
MUTED = colors.HexColor('#596778')
PALE = colors.HexColor('#F3F6FA')
LINE = colors.HexColor('#D8E0EB')
PAGE_W, PAGE_H = A4
MARGIN = 48
WIDTH = PAGE_W - 2 * MARGIN
COMMIT = 'main'

for name, filename in [('Body', 'calibri.ttf'), ('Body-Bold', 'calibrib.ttf'),
                       ('Body-Italic', 'calibrii.ttf'), ('Mono', 'consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name, 'C:/Windows/Fonts/' + filename))
pdfmetrics.registerFontFamily('Body', normal='Body', bold='Body-Bold', italic='Body-Italic', boldItalic='Body-Bold')

styles = {
 'title': ParagraphStyle('title', fontName='Body-Bold', fontSize=26, leading=29, textColor=NAVY, spaceAfter=13),
 'h2': ParagraphStyle('h2', fontName='Body-Bold', fontSize=16.2, leading=20, textColor=NAVY, spaceBefore=19, spaceAfter=9, keepWithNext=True),
 'h3': ParagraphStyle('h3', fontName='Body-Bold', fontSize=12.6, leading=16, textColor=NAVY, spaceBefore=12, spaceAfter=6, keepWithNext=True),
 'h4': ParagraphStyle('h4', fontName='Body-Bold', fontSize=11.2, leading=14, textColor=NAVY, spaceBefore=9, spaceAfter=5, keepWithNext=True),
 'body': ParagraphStyle('body', fontName='Body', fontSize=11, leading=14.8, textColor=INK, spaceAfter=8, allowWidows=0, allowOrphans=0),
 'source': ParagraphStyle('source', fontName='Body', fontSize=9.1, leading=11.7, textColor=MUTED, spaceAfter=8),
 'bullet': ParagraphStyle('bullet', fontName='Body', fontSize=11, leading=14.8, textColor=INK, leftIndent=13, firstLineIndent=-10, spaceAfter=6, allowWidows=0, allowOrphans=0),
 'cell': ParagraphStyle('cell', fontName='Body', fontSize=9.4, leading=12.1, textColor=INK, spaceAfter=0, splitLongWords=1),
 'cellhead': ParagraphStyle('cellhead', fontName='Body-Bold', fontSize=9.3, leading=12, textColor=colors.white, spaceAfter=0),
}

def slug(text):
    text = re.sub(r'`([^`]+)`', r'\1', text).lower()
    text = re.sub(r'[^\w\s-]', '', text)
    return re.sub(r'\s+', '-', text.strip())

def target_url(target):
    if target.startswith(('#', 'http://', 'https://')):
        return target
    path = (REV / unquote(target.split('#')[0])).resolve()
    if path.is_relative_to(ROOT):
        fragment = '#' + target.split('#', 1)[1] if '#' in target else ''
        return 'https://github.com/kapiltrip/systemverilog-from-beginning/blob/' + COMMIT + '/' + quote(path.relative_to(ROOT).as_posix(), safe='/') + fragment
    return None

def inline(text):
    rendered=[]
    i=0
    while i<len(text):
        if text[i]=='`':
            run=1
            while i+run<len(text) and text[i+run]=='`':
                run+=1
            end=text.find('`'*run,i+run)
            if end>=0:
                code=text[i+run:end].replace(r'\|', '|')
                if run>1 and code.startswith(' ') and code.endswith(' '):
                    code=code[1:-1]
                rendered.append('<font name="Mono" size="9">'+html.escape(code)+'</font>')
                i=end+run
                continue
        if text[i]=='$':
            end=text.find('$', i+1)
            if end>=0:
                math=text[i+1:end]
                for old,new in [(r'\times','×'), (r'\%','%'),
                                (r'\ldots','...'), (r'\le','≤'),
                                (r'\ge','≥'), (r'\cap','∩')]:
                    math=math.replace(old,new)
                rendered.append(html.escape(math))
                i=end+1
                continue
        if text[i]=='[':
            middle=text.find('](',i+1)
            if middle>=0:
                end=text.find(')',middle+2)
                if end>=0:
                    label=inline(text[i+1:middle])
                    url=target_url(text[middle+2:end])
                    rendered.append(f'<link href="{html.escape(url, quote=True)}" color="#0563C1">{label}</link>' if url else label)
                    i=end+1
                    continue
        if text.startswith('**',i):
            end=text.find('**',i+2)
            if end>=0:
                rendered.append('<b>'+inline(text[i+2:end])+'</b>')
                i=end+2
                continue
        if text[i]=='*':
            end=text.find('*',i+1)
            if end>=0:
                rendered.append('<i>'+inline(text[i+1:end])+'</i>')
                i=end+1
                continue
        if text.startswith('<br>',i):
            rendered.append('<br/>'); i+=4; continue
        rendered.append(html.escape(text[i]))
        i+=1
    return ''.join(rendered)

class CodeBlock(Flowable):
    def __init__(self, lines, language='', continuation=False):
        Flowable.__init__(self)
        self.lines = lines
        self.language = language
        self.continuation = continuation
        self.fontsize = 8.8
        self.leading = 11.6
        self.pad = 10
        self.spaceBefore = 2
        self.spaceAfter = 9
    def wrap(self, width, height):
        self.width = width
        longest = max((pdfmetrics.stringWidth(s, 'Mono', self.fontsize) for s in self.lines), default=0)
        if longest > width - 2*self.pad:
            raise ValueError('Code line exceeds readable width: '+max(self.lines,key=len))
        self.height = len(self.lines)*self.leading + 2*self.pad + (13 if self.continuation else 0)
        return self.width, self.height
    def split(self, width, height):
        if len(self.lines) <= 16:
            return []
        n = int((height-2*self.pad-(13 if self.continuation else 0)) / self.leading)
        n = min(n, len(self.lines)-7)
        if n < 8:
            return []
        blank_breaks = [i for i in range(max(8,n-10),n+1) if not self.lines[i-1].strip()]
        if blank_breaks:
            n = blank_breaks[-1]
        return [CodeBlock(self.lines[:n], self.language, self.continuation), CodeBlock(self.lines[n:], self.language, True)]
    def draw(self):
        c = self.canv
        c.setFillColor(PALE)
        c.roundRect(0, 0, self.width, self.height, 4, fill=1, stroke=0)
        c.setStrokeColor(LINE)
        c.line(0, 0, 0, self.height)
        c.setFont('Mono', self.fontsize)
        y = self.height - self.pad - self.fontsize
        if self.continuation:
            c.setFillColor(MUTED)
            c.setFont('Body-Italic', 8)
            c.drawString(self.pad, y, 'Code continued')
            c.setFont('Mono', self.fontsize)
            y -= 13
        for line in self.lines:
            if line.lstrip().startswith('//'):
                c.setFillColor(MUTED)
            else:
                c.setFillColor(INK)
            c.drawString(self.pad, y, line)
            y -= self.leading

class RevisionDoc(BaseDocTemplate):
    def __init__(self, path):
        BaseDocTemplate.__init__(self, str(path), pagesize=A4, leftMargin=MARGIN,
          rightMargin=MARGIN, topMargin=48, bottomMargin=46, title='SystemVerilog Section 6: Randomization',
          author='SystemVerilog study notes', subject='Constrained randomization explained from Kapil\'s Section 6 practice',
          pageCompression=1)
        self.headings = []
        frame = Frame(MARGIN, 46, WIDTH, PAGE_H-94, leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0)
        self.addPageTemplates(PageTemplate(id='normal', frames=frame, onPage=self.page_decoration))
    def beforeDocument(self):
        self.headings = []
    def page_decoration(self, c, doc):
        c.saveState()
        c.setStrokeColor(LINE)
        c.line(MARGIN, PAGE_H-31, PAGE_W-MARGIN, PAGE_H-31)
        c.setFillColor(MUTED)
        c.setFont('Body', 8.2)
        c.drawString(MARGIN, PAGE_H-24, 'SYSTEMVERILOG  /  SECTION 6')
        c.drawRightString(PAGE_W-MARGIN, PAGE_H-24, 'Revision from your practice')
        c.line(MARGIN, 32, PAGE_W-MARGIN, 32)
        c.drawString(MARGIN, 20, 'Randomization  |  Definitions, reasoning, and practice')
        c.drawRightString(PAGE_W-MARGIN, 20, str(doc.page))
        c.restoreState()
    def afterFlowable(self, flow):
        if isinstance(flow, Paragraph) and hasattr(flow, 'bookmark'):
            key, title, level = flow.bookmark
            self.canv.bookmarkHorizontalAbsolute(key, self.frame._y + flow.height)
            self.canv.addOutlineEntry(title, key, level, closed=(level>0))
            self.headings.append({'title':title,'page':self.page,'level':level,'key':key})
            if level == 0:
                self.notify('TOCEntry', (0, inline(title), self.page, key))

def split_row(line):
    out, current, ticks = [], [], False
    for ch in line.strip().strip('|'):
        if ch == '`':
            ticks = not ticks
        if ch == '|' and not ticks:
            out.append(''.join(current).strip()); current=[]
        else:
            current.append(ch)
    out.append(''.join(current).strip())
    return out

def table(lines):
    rows = [split_row(line) for line in lines]
    rows = [r for r in rows if not all(re.fullmatch(r':?-{2,}:?', c.replace(' ', '')) for c in r)]
    n = len(rows[0])
    rows = [r + ['']*(n-len(r)) for r in rows]
    if any(len(r)!=n for r in rows):
        raise ValueError('Inconsistent table columns: '+str(rows[:2]))
    rawweights = []
    for col in range(n):
        lengths = [len(re.sub(r'\[([^]]+)\]\([^)]+\)',r'\1',row[col])) for row in rows]
        rawweights.append(max(10,min(45,sum(lengths)/len(lengths)))**0.62)
    if n == 2:
        fractions = [0.33, 0.67]
    else:
        total = sum(rawweights)
        fractions = [v/total for v in rawweights]
    widths = [WIDTH*f for f in fractions]
    rendered = [[Paragraph(inline(cell), styles['cellhead' if idx==0 else 'cell']) for cell in row] for idx,row in enumerate(rows)]
    t = Table(rendered, colWidths=widths, repeatRows=1, hAlign='LEFT', spaceBefore=3, spaceAfter=10)
    t.setStyle(TableStyle([
       ('BACKGROUND',(0,0),(-1,0),NAVY),
       ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),
       ('VALIGN',(0,0),(-1,-1),'TOP'),
       ('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),
       ('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6),
       ('LINEBELOW',(0,0),(-1,0),0.4,NAVY),
       ('LINEBELOW',(0,1),(-1,-1),0.25,LINE),
    ]))
    return KeepTogether([t]) if len(rows) <= 8 else t

def build():
    WORK.mkdir(parents=True, exist_ok=True)
    text = SOURCE.read_text(encoding='utf-8')
    lines = text.splitlines()
    story=[]
    i=0
    in_contents=False
    while i<len(lines):
        line=lines[i]
        if line.strip()=='<!-- PDF PAGE BREAK -->':
            story.append(PageBreak()); i+=1; continue
        if line.strip()=='## Contents':
            story.append(Paragraph('Contents', styles['h2']))
            toc=TableOfContents()
            toc.levelStyles=[ParagraphStyle('toc',fontName='Body',fontSize=10.1,leading=14.2,spaceBefore=3.2,textColor=INK)]
            toc.dotsMinLevel=0
            story.append(toc)
            i+=1
            while i<len(lines) and not lines[i].startswith('## '):
                i+=1
            story.append(PageBreak())
            continue
        if not line.strip() or line.strip()=='---' or line.startswith('<!--'):
            i+=1; continue
        if line.startswith('```'):
            language=line[3:]; code=[]; i+=1
            while i<len(lines) and not lines[i].startswith('```'):
                code.append(lines[i].expandtabs(2)); i+=1
            story.append(CodeBlock(code,language)); i+=1; continue
        match=re.match(r'^(#{1,4})\s+(.+)',line)
        if match:
            level=len(match[1]); title=match[2]
            if level==1:
                title_text=inline(title)
                if ': ' in title_text:
                    title_text=title_text.replace(': ', '<br/>', 1)
                story.append(Paragraph(title_text,styles['title']))
            else:
                if level==2:
                    story.append(CondPageBreak(190))
                p=Paragraph(inline(title),styles[f'h{level}'])
                p.bookmark=(slug(title),re.sub(r'[`*]','',title), min(level-2,1))
                story.append(p)
            i+=1; continue
        if line.lstrip().startswith('|'):
            chunk=[]
            while i<len(lines) and lines[i].lstrip().startswith('|'):
                chunk.append(lines[i]); i+=1
            story.append(table(chunk)); continue
        bullet=re.match(r'^\s*(?:[-*]|(\d+)\.)\s+(.+)',line)
        if bullet:
            prefix=(bullet[1]+'.') if bullet[1] else '\u2022'
            story.append(Paragraph(prefix+' '+inline(bullet[2]),styles['bullet'])); i+=1; continue
        if line.startswith('> '):
            quote_text=line[2:]
            story.append(Paragraph(inline(quote_text),styles['body'])); i+=1; continue
        para=[line.strip()]; i+=1
        while i<len(lines) and lines[i].strip() and not re.match(r'^(#|\||```|[-*] |1\. |>|<!--)',lines[i]):
            para.append(lines[i].strip()); i+=1
        joined=' '.join(para)
        style='source' if joined.startswith(('Sources:', '**Sources', 'Source:', '**Source', 'Reference:', '**Reference')) else 'body'
        paragraph=Paragraph(inline(joined),styles[style])
        if style=='source' and story and isinstance(story[-1], Paragraph):
            story[-1].keepWithNext=True
        if joined.endswith(':') or joined.startswith('**Problem '):
            paragraph.keepWithNext=True
        story.append(paragraph)
    doc=RevisionDoc(OUTPUT)
    doc.multiBuild(story)
    (WORK/'pdf-navigation.json').write_text(json.dumps(doc.headings,indent=2),encoding='utf-8')
    print('Created',OUTPUT)
    print('Pages:',doc.page)
    print('Bookmarks:',len(doc.headings))

if __name__=='__main__':
    build()
