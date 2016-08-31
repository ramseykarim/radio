;5.1


pro fivepointone

div = 10
volt = '1V'
N = 512
;restore, '5_1.sav'

psopen, '5_1.ps', xsize=20, ysize=20, /color, /inches

data = getsample(div, N, volt)
!p.multi = [0,2,2]
plotsignal, data, div, 'junk', '1 MHz mixed w/ 1.05 MHz', /MYTITLE
plotspectrum, data, div, 'junk', '1 MHz mixed w/ 1.05 MHz', /MYTITLE

save, data, FILENAME='5_1.sav'
a = 20
b = N/2 - 1 - a
c = N/2 + a
spec = data[*, 2]
freqs = data[*, 3]
times = data[*, 1]

for i=0,b do spec[i] = 0
for i=c,N-1 do spec[i] = 0

ps = spec * conj(spec)
dft, times, spec, freqs, output, /inverse

plot, times*10.^6, output, color=!black, psym=-4, title='Filtered Signal', $
      xtitle = 'Time (microseconds)', ytitle='Amplitude'

plot, freqs, ps, color=!black, psym=-4, title='Filtered Spectrum', $
      xtitle = 'Freq (MHz)', ytitle='Power'

psclose

end
