;Batch file for 3.3

;Sampling at 6.25 MHz.
;Taking data set of f = 6.25 MHz.

pro threepointthree

freq = 6250000.0
div = 10
N = 16

srs1_frq, freq
print, 'Frequency changed to ',strtrim(string(freq), 1)
wait, 3
data = getsample(div, N, '1V')
print, 'Data taken'
psopen, '3_3PlotViolateNyquistEqual.ps', $
        xsize=20, ysize=16, /inches, /color
!p.multi = [0,1,2]
plotsignal, data, div, freq
plotspectrum, data, div, freq
psclose

;Sampling at 62.5 kHz.
;Taking data set of f = 6.23 MHz.

freq = 6230000.0
div = 1000

srs1_frq, freq
print, 'Frequency changed to ',strtrim(string(freq), 1)
wait, 3
data = getsample(div, N, '1V')
print, 'Data taken'
psopen, '3_3PlotViolateNyquistGreater.ps', $
        xsize=20, ysize=16, /inches, /color
!p.multi = [0,1,2]
plotsignal, data, div, freq
plotspectrum, data, div, freq
psclose

end
