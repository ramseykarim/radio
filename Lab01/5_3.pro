;5.3

pro short, div, N, datas, res, ims, times, freqs, comps, comp_dfts, pss

div = 1
N = 512

datas = getsample(div, N, '1V', /DUAL)

res = datas[*, 0]
ims = datas[*, 4]
times = datas[*, 1]
freqs = datas[*, 3]
comps = complex(res, ims)
dft, times, comps, freqs, comp_dfts

plot, [times*10.^6, times*10.^6], [min(res), max(res)], $
      color=!black, title='Real&imag (re=green) short cable (0deg)', $
      xtitle='Time (microseconds)', ytitle='Voltage (V)', $
      background = !grey, /nodata;, charsize=2
oplot, times*10.^6, imaginary(comps), color=!orange
oplot, times*10.^6, real_part(comps), color=!forest

pss = comp_dfts * conj(comp_dfts)
plot, freqs/10.^6, pss, color=!black, psym=-4, title='Power Spec, complex included, short cable', $
      xtitle='Frequency (MHz)', ytitle='Power';, charsize=2

end


pro long, div, N, datal, rel, iml, timel, freql, compl, comp_dftl, psl

div = 1
N = 512

datal = getsample(div, N, '1V', /DUAL)

rel = datal[*, 0]
iml = datal[*, 4]
timel = datal[*, 1]
freql = datal[*, 3]
compl = complex(rel, iml)
dft, timel, compl, freql, comp_dftl

plot, [timel*10.^6, timel*10.^6], [min(rel), max(rel)], $
      color=!black, title='Real&imag (re=red) long cable (90deg)', $
      xtitle='Time (microseconds)', ytitle='Voltage (V)', $
      background = !grey, /nodata;, charsize=2
oplot, timel*10.^6, imaginary(compl), color=!purple
oplot, timel*10.^6, real_part(compl), color=!red

psl = comp_dftl * conj(comp_dftl)
plot, freql/10.^6, psl, color=!black, psym=-4, title='Power Spec, complex included, long cable', $
      xtitle='Frequency (MHz)', ytitle='Power';, charsize=2

end

pro compare

div = 1
N = 512
datas = 0
res = 0
ims = 0
times = 0
freqs = 0
comps = 0
comp_dfts = 0
pss = 0

datal = 0
rel = 0
iml = 0
timel = 0
freql = 0
compl = 0
comp_dftl = 0
psl = 0

psopen, '5_3LowerSidebandCase.ps', xsize=25, ysize=25, /color, /inches
!p.multi = [0,2,2]

short, div, N, datal, res, ims, times, freqs, comps, comp_dfts, pss

print, 'Data taken, graphed'
print, 'Now change the setup'
print, 'Press a key to take next data sample (long cable)'
next = get_kbrd()

long, div, N, datal, rel, iml, timel, freql, compl, comp_dftl, psl

save, /ALL, FILENAME='5_3NEWSAVE_LOW.sav'
psclose

end
