;Batch file for 3.4

;Sampling at 6.25 MHz
;Taking 4 data sets at 500 kHz, 625 kHz, 1 MHz, 2 MHz.

pro threepointfour

div = 10
N = 32
freqs = [500000.0, 625000.0, 1000000.0, 2000000.0]
volt = '1V'

for i=0,3 do begin
   freq = freqs[i]
   i_str = strtrim(string(i),1)
   srs1_frq, freq
   print, 'Frequency changed to ',strtrim(string(freq), 1)
   wait, 3
   data = getsample(div, N, volt)
   print, 'Data taken'
   psopen, '3_4PlotSpectrum'+i_str+'.ps', $
           xsize=20, ysize=16, /inches, /color
   !p.multi = [0,1,3]
   plotspectrum, data, div, freq, /VOLTAGE
   psclose
endfor

end
