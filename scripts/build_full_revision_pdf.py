# scripts/build_full_revision_pdf.py
"""
Builds publication-quality PDFs from the Master Markdown Revision Document
using ReportLab.
Outputs to:
- docs/SystemVerilog_Data_Types_and_OOP_Revision.pdf
- SV Basics/Revision/Data-Types-and-OOP-Revision.pdf
"""

import sys
import re
import html
import json
import shutil
from pathlib import Path

from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph,
    Spacer, PageBreak, Table, TableStyle, Flowable
)
from reportlab.platypus.tableofcontents import TableOfContents

ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = ROOT / "docs"
REV_DIR = ROOT / "SV Basics" / "Revision"

MD_SOURCE = DOCS_DIR / "SystemVerilog_Data_Types_and_OOP_Revision.md"
PDF_DOCS = DOCS_DIR / "SystemVerilog_Data_Types_and_OOP_Revision.pdf"
PDF_REV = REV_DIR / "Data-Types-and-OOP-Revision.pdf"

NAVY = colors.HexColor('#002060')
BLUE = colors.HexColor('#0563C1')
INK = colors.HexColor('#202C3A')
MUTED = colors.HexColor('#596778')
PALE = colors.HexColor('#F3F6FA')
LINE = colors.HexColor('#D8E0EB')
PAGE_W, PAGE_H = A4
MARGIN = 42
WIDTH = PAGE_W - 2 * MARGIN

# Register clean TrueType fonts from Windows Fonts directory
for name, filename in [('Body', 'calibri.ttf'), ('Body-Bold', 'calibrib.ttf'),
                       ('Body-Italic', 'calibrii.ttf'), ('Mono', 'consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name, 'C:/Windows/Fonts/' + filename))
pdfmetrics.registerFontFamily('Body', normal='Body', bold='Body-Bold', italic='Body-Italic', boldItalic='Body-Bold')

styles = {
    'title': ParagraphStyle('title', fontName='Body-Bold', fontSize=22, leading=26, textColor=NAVY, spaceAfter=8),
    'subtitle': ParagraphStyle('subtitle', fontName='Body', fontSize=10.5, leading=14.5, textColor=MUTED, spaceAfter=12),
    'h2': ParagraphStyle('h2', fontName='Body-Bold', fontSize=14.5, leading=18, textColor=NAVY, spaceBefore=14, spaceAfter=7, keepWithNext=True),
    'h3': ParagraphStyle('h3', fontName='Body-Bold', fontSize=11.5, leading=14.5, textColor=NAVY, spaceBefore=10, spaceAfter=4, keepWithNext=True),
    'h4': ParagraphStyle('h4', fontName='Body-Bold', fontSize=10, leading=13, textColor=NAVY, spaceBefore=7, spaceAfter=3, keepWithNext=True),
    'body': ParagraphStyle('body', fontName='Body', fontSize=9.5, leading=13.2, textColor=INK, spaceAfter=5, allowWidows=0, allowOrphans=0),
    'quote': ParagraphStyle('quote', fontName='Body-Italic', fontSize=9.2, leading=12.8, textColor=NAVY, leftIndent=10, spaceAfter=5),
    'bullet': ParagraphStyle('bullet', fontName='Body', fontSize=9.5, leading=13.2, textColor=INK, leftIndent=12, firstLineIndent=-8, spaceAfter=3),
    'cell': ParagraphStyle('cell', fontName='Body', fontSize=8.5, leading=11, textColor=INK, spaceAfter=0, splitLongWords=1),
    'cellhead': ParagraphStyle('cellhead', fontName='Body-Bold', fontSize=8.5, leading=11, textColor=colors.white, spaceAfter=0),
}

def clean_text_for_pdf(text):
    text = (text.replace('\u2014', ' -- ')
                .replace('\u2013', '-')
                .replace('\u2018', "'")
                .replace('\u2019', "'")
                .replace('\u201c', '"')
                .replace('\u201d', '"')
                .replace('\u2192', '->')
                .replace('\u00d7', 'x'))
    return text

def slug(text):
    text = clean_text_for_pdf(text)
    text = re.sub(r'`([^`]+)`', r'\1', text).lower()
    text = re.sub(r'[^\w\s-]', '', text)
    return re.sub(r'\s+', '-', text.strip())

def inline(text):
    text = clean_text_for_pdf(text)
    slots = []
    def hold(rendered):
        slots.append(rendered)
        return f'ZZTOKEN{len(slots)-1}ZZ'
    def link(m):
        label, dest = m.group(1), m.group(2)
        label = inline(label)
        if dest.startswith(('http://', 'https://')):
            return hold(f'<link href="{html.escape(dest, quote=True)}" color="#0563C1">{label}</link>')
        return hold(label)
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', link, text)
    text = re.sub(r'`([^`]+)`', lambda m: hold('<font name="Mono" size="8.0">'+html.escape(m.group(1))+'</font>'), text)
    text = html.escape(text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'(?<!\*)\*([^*]+)\*(?!\*)', r'<i>\1</i>', text)
    text = text.replace('&lt;br&gt;', '<br/>').replace('&lt;br/&gt;', '<br/>')
    for i, value in enumerate(slots):
        text = text.replace(f'ZZTOKEN{i}ZZ', value)
    return text

class CodeBlock(Flowable):
    def __init__(self, lines, language='', continuation=False):
        Flowable.__init__(self)
        self.lines = [clean_text_for_pdf(l) for l in lines]
        self.language = language
        self.continuation = continuation
        self.fontsize = 8.0
        self.leading = 10.4
        self.pad = 7
        self.spaceBefore = 3
        self.spaceAfter = 7

    def wrap(self, width, height):
        self.width = width
        longest = max((pdfmetrics.stringWidth(s, 'Mono', self.fontsize) for s in self.lines), default=0)
        if longest > width - 2 * self.pad:
            self.fontsize = max(6.8, self.fontsize * (width - 2 * self.pad) / longest)
            self.leading = self.fontsize * 1.3
        self.height = len(self.lines) * self.leading + 2 * self.pad
        return self.width, self.height

    def split(self, width, height):
        n = int((height - 2 * self.pad) / self.leading)
        if n < 4 or len(self.lines) - n < 3:
            return []
        return [CodeBlock(self.lines[:n], self.language, self.continuation), CodeBlock(self.lines[n:], self.language, True)]

    def draw(self):
        c = self.canv
        c.setFillColor(PALE)
        c.roundRect(0, 0, self.width, self.height, 4, fill=1, stroke=0)
        c.setStrokeColor(LINE)
        c.line(0, 0, 0, self.height)
        c.setFont('Mono', self.fontsize)
        y = self.height - self.pad - self.fontsize
        for line in self.lines:
            if line.lstrip().startswith('//') or line.lstrip().startswith('/*'):
                c.setFillColor(MUTED)
            else:
                c.setFillColor(INK)
            c.drawString(self.pad, y, line)
            y -= self.leading

class RevisionDoc(BaseDocTemplate):
    def __init__(self, path):
        BaseDocTemplate.__init__(
            self, str(path), pagesize=A4, leftMargin=MARGIN, rightMargin=MARGIN,
            topMargin=42, bottomMargin=40,
            title='SystemVerilog Unified Revision: Data Types and OOP',
            author='Kapil Tripathi',
            subject='Unified Revision Guide Mapping GitHub Lessons and Laboratory Practice',
            pageCompression=1
        )
        self.headings = []
        frame = Frame(MARGIN, 40, WIDTH, PAGE_H - 82, leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0)
        self.addPageTemplates(PageTemplate(id='normal', frames=frame, onPage=self.page_decoration))

    def beforeDocument(self):
        self.headings = []

    def page_decoration(self, c, doc):
        c.saveState()
        c.setStrokeColor(LINE)
        c.line(MARGIN, PAGE_H - 26, PAGE_W - MARGIN, PAGE_H - 26)
        c.setFillColor(MUTED)
        c.setFont('Body', 7.8)
        c.drawString(MARGIN, PAGE_H - 20, 'SYSTEMVERILOG REVISION  |  DATA TYPES AND OOP')
        c.drawRightString(PAGE_W - MARGIN, PAGE_H - 20, 'First & Second Revision Synthesis')
        c.line(MARGIN, 28, PAGE_W - MARGIN, 28)
        c.drawString(MARGIN, 16, 'SystemVerilog Master Revision Handbook  |  Data Types, Subroutines, OOP & Randomization')
        c.drawRightString(PAGE_W - MARGIN, 16, f'Page {doc.page}')
        c.restoreState()

    def afterFlowable(self, flow):
        if isinstance(flow, Paragraph) and hasattr(flow, 'bookmark'):
            key, title, level = flow.bookmark
            title_clean = clean_text_for_pdf(title)
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(title_clean, key, level, closed=(level > 0))
            self.headings.append({'title': title_clean, 'page': self.page, 'level': level, 'key': key})
            if level == 0:
                self.notify('TOCEntry', (0, inline(title_clean), self.page, key))

def split_row(line):
    out, current, ticks = [], [], False
    for ch in line.strip().strip('|'):
        if ch == '`':
            ticks = not ticks
        if ch == '|' and not ticks:
            out.append(''.join(current).strip())
            current = []
        else:
            current.append(ch)
    out.append(''.join(current).strip())
    return out

def build_table(lines):
    rows = [split_row(line) for line in lines]
    rows = [r for r in rows if not all(re.fullmatch(r':?-{2,}:?', c.replace(' ', '')) for c in r)]
    if not rows:
        return None
    n = len(rows[0])
    rows = [r + [''] * (n - len(r)) for r in rows]
    rawweights = []
    for col in range(n):
        lengths = [len(re.sub(r'\[([^]]+)\]\([^)]+\)', r'\1', row[col])) for row in rows]
        rawweights.append(max(10, min(50, sum(lengths) / len(lengths))) ** 0.65)
    if n == 2:
        fractions = [0.28, 0.72]
    elif n == 3:
        fractions = [0.22, 0.39, 0.39]
    elif n == 4:
        fractions = [0.18, 0.28, 0.28, 0.26]
    elif n == 5:
        fractions = [0.13, 0.21, 0.22, 0.24, 0.20]
    elif n == 6:
        fractions = [0.12, 0.16, 0.16, 0.22, 0.18, 0.16]
    else:
        total = sum(rawweights)
        fractions = [v / total for v in rawweights]
    widths = [WIDTH * f for f in fractions]
    rendered = [
        [Paragraph(inline(cell), styles['cellhead' if idx == 0 else 'cell']) for cell in row]
        for idx, row in enumerate(rows)
    ]
    t = Table(rendered, colWidths=widths, repeatRows=1, hAlign='LEFT', spaceBefore=3, spaceAfter=7)
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, PALE]),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LINEBELOW', (0, 0), (-1, 0), 0.5, NAVY),
        ('LINEBELOW', (0, 1), (-1, -1), 0.25, LINE),
    ]))
    return t

def build_pdf():
    print(f"Reading markdown source from {MD_SOURCE}...")
    text = MD_SOURCE.read_text(encoding='utf-8')
    lines = text.splitlines()
    story = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '<!-- PDF PAGE BREAK -->':
            story.append(PageBreak())
            i += 1
            continue
        if line.strip() == '## Contents':
            story.append(Paragraph('Contents', styles['h2']))
            toc = TableOfContents()
            toc.levelStyles = [
                ParagraphStyle('toc', fontName='Body', fontSize=9.5, leading=13.5, spaceBefore=2.5, textColor=INK)
            ]
            toc.dotsMinLevel = 0
            story.append(toc)
            i += 1
            while i < len(lines) and not lines[i].startswith('## '):
                i += 1
            story.append(PageBreak())
            continue
        if not line.strip() or line.strip() == '---' or line.startswith('<!--'):
            i += 1
            continue
        if line.startswith('```'):
            language = line[3:]
            code = []
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code.append(lines[i].expandtabs(2))
                i += 1
            story.append(CodeBlock(code, language))
            i += 1
            continue
        match = re.match(r'^(#{1,4})\s+(.+)', line)
        if match:
            level = len(match[1])
            title = match[2]
            if level == 1:
                story.append(Paragraph(inline(title), styles['title']))
            else:
                p = Paragraph(inline(title), styles[f'h{level}'])
                p.bookmark = (slug(title), clean_text_for_pdf(re.sub(r'[`*]', '', title)), min(level - 2, 1))
                story.append(p)
            i += 1
            continue
        if line.lstrip().startswith('|'):
            chunk = []
            while i < len(lines) and lines[i].lstrip().startswith('|'):
                chunk.append(lines[i])
                i += 1
            t = build_table(chunk)
            if t:
                story.append(t)
            continue
        bullet = re.match(r'^\s*(?:[-*]|(\d+)\.)\s+(.+)', line)
        if bullet:
            prefix = (bullet[1] + '.') if bullet[1] else '\u2022'
            story.append(Paragraph(prefix + ' ' + inline(bullet[2]), styles['bullet']))
            i += 1
            continue
        if line.startswith('> '):
            quote_text = line[2:]
            story.append(Paragraph(inline(quote_text), styles['quote']))
            i += 1
            continue
        para = [line.strip()]
        i += 1
        while i < len(lines) and lines[i].strip() and not re.match(r'^(#|\||```|[-*] |\d+\. |>|<!--)', lines[i]):
            para.append(lines[i].strip())
            i += 1
        joined = ' '.join(para)
        story.append(Paragraph(inline(joined), styles['body']))

    print(f"Compiling PDF with ReportLab to {PDF_DOCS}...")
    doc = RevisionDoc(PDF_DOCS)
    doc.multiBuild(story)
    print(f"Created {PDF_DOCS} (Total pages: {doc.page}, Bookmarks: {len(doc.headings)})")
    
    # Copy to Revision directory as well
    shutil.copyfile(PDF_DOCS, PDF_REV)
    print(f"Copied PDF to {PDF_REV}")

if __name__ == "__main__":
    build_pdf()
