" Powerline vim example
" Run with :source %

set stl=%!DynStl()

function! DynStl()
python <<EOF

import vim
import os
import re
import sys
sys.path.append('.')

from lib.core import Powerline, Segment
from lib.renderers import VimSegmentRenderer

winwidth = int(vim.eval('winwidth(0)'))

# Prepare segment contents
mode = {
	'n': 'NORMAL',
	'v': 'VISUAL',
	'V': 'V·LINE',
	'': 'V·BLCK',
	's': 'SELECT',
	'S': 'SELECT',
	'': 'SELECT',
	'i': 'INSERT',
	'R': 'REPLACE',
	'Rv': 'REPLACE',
	}[vim.eval('mode()')]

branch = vim.eval('fugitive#head(5)')

line_current = int(vim.eval('line(".")'))
line_end = int(vim.eval('line("$")'))
line_percent = int(float(line_current) / float(line_end) * 100)

# Fun gradient colored percent segment
line_percent_gradient = [160, 166, 172, 178, 184, 190]
line_percent_color = line_percent_gradient[int((len(line_percent_gradient) - 1) * line_percent / 100)]

col_current = vim.eval('col(".")')

filepath = os.path.split(vim.eval('expand("%:~:.")'))
if filepath[0]:
	filepath[0] += os.sep

powerline = Powerline([
	Segment(mode, 22, 148, attr=Segment.ATTR_BOLD),
	Segment('⭠ ' + branch, 250, 240, priority=10),
	Segment(filepath[0], 250, 240, draw_divider=False, priority=5),
	Segment(filepath[1], 231, 240, attr=Segment.ATTR_BOLD),
	Segment(filler=True, fg=236, bg=236),
	Segment(vim.eval('&ff'), 247, 236, side='r', priority=50),
	Segment(vim.eval('&fenc'), 247, 236, side='r', priority=50),
	Segment(vim.eval('&ft'), 247, 236, side='r', priority=50),
	Segment(str(line_percent).rjust(3) + '%', line_percent_color, 240, side='r', priority=30),
	Segment('⭡ ', 239, 252, side='r'),
	Segment(str(line_current).rjust(3), 235, 252, attr=Segment.ATTR_BOLD, side='r', draw_divider=False),
	Segment(':' + str(col_current).ljust(2), 244, 252, side='r', priority=30, draw_divider=False),
])

renderer = VimSegmentRenderer()
stl = powerline.render(renderer, winwidth)

# Escape percent chars in the statusline, but only if they aren't part of any stl escape sequence
stl = re.sub('(\w+)\%(?![-{()<=#*%])', '\\1%%', stl)

# Create highlighting groups
for group, hl in renderer.hl_groups.items():
	if int(vim.eval('hlexists("{0}")'.format(group))):
		# Only create hl group if it doesn't already exist
		continue

	vim.command('hi {group} ctermfg={ctermfg} guifg={guifg} guibg={guibg} ctermbg={ctermbg} cterm={attr} gui={attr}'.format(
			group=group,
			ctermfg=hl['ctermfg'],
			guifg='#{0:06x}'.format(hl['guifg']) if hl['guifg'] != 'NONE' else 'NONE',
			ctermbg=hl['ctermbg'],
			guibg='#{0:06x}'.format(hl['guibg']) if hl['guibg'] != 'NONE' else 'NONE',
			attr=','.join(hl['attr']),
		))

vim.command('return "{0}"'.format(stl))

EOF
endfunction
