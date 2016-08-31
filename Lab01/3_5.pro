;Batch file for 3.5

;Sampling at 625 kHz
;Signal Frequency = 62.5 kHz

;Square wave

;psopen, '3_5SquareWave.ps', xsize=20, ysize=16, /inches, /color

;div=10

;data = getsample(div, 2048, '1V')
;!p.multi = [0,1,3]
;plotsignal, data, div, '62.5 kHz', 'Square Wave, 62.5 kHz // Sampled at 6.25 MHz', /MYTITLE
;plotspectrum, data, div, '62.5 kHz', 'Square Wave Power Spectrum', /MYTITLE
;plotspectrum, data, div, '62.5 kHz', $
;              'Square Wave Power Spectrum Zoomed', /MYTITLE, yrange=[0,40]

;savedata, data, 100, '62.5 kHz', 'SquareWave'

;psclose

;help, data






;Triangle Wave

;psopen, '3_5TriangleWave.ps', xsize=20, ysize=16, /inches, /color

;data = getsample(div, 2048, '1V')
;!p.multi = [0,1,3]
;plotsignal, data, div, '62.5 kHz', 'Triangle Wave, 62.5 kHz // Sampled at 625 kHz', /MYTITLE
;plotspectrum, data, div, '62.5 kHz', 'Triangle Wave Power Spectrum', /MYTITLE
;plotspectrum, data, div, '62.5 kHz', $
;              'Triangle Wave Power Spectrum Zoomed', /MYTITLE, yrange=[0,20]

;psclose




;Filtering
restore, 'SquareWave.sav'
help, data
ps_ch, '3_6Filtering.ps', xsize=20, ysize=30, /inches, /color, /defaults
filtering, data
psclose
