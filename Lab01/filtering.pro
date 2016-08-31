;+
;NAME:     FILTERING
;
;DESCRIPTION:
;          Built for the 2048x4-element DATA array from the GETSAMPLE procedure.
;          Lab 1, part 3.6.
;          Fourier filters and plots the wave in steps.
;
;
;CALLING SEQUENCE:
;          filtering, data
;
;INPUTS:
;          DATA is the output of GETSAMPLE.
;
;-


pro filtering, data

spectrum = data[*, 2]

a = 400
b = 700
c = 850
d = 985

last = 2047
e = last - a
f = last - b
g = last - c
h = last - d

spec1 = spectrum
spec2 = spectrum
spec3 = spectrum
spec4 = spectrum

for i=0,a do spec1[i] = 0
for i=e,last do spec1[i] = 0

for i=0,b do spec2[i] = 0
for i=f,last do spec2[i] = 0

for i=0,c do spec3[i] = 0
for i=g,last do spec3[i] = 0

for i=0,d do spec4[i] = 0
for i=h,last do spec4[i] = 0

time = data[*, 1]
freqs = data[*, 3]

psorig = spectrum*conj(spectrum)
ps1 = spec1*conj(spec1)
ps2 = spec2*conj(spec2)
ps3 = spec3*conj(spec3)
ps4 = spec4*conj(spec4)


dft, freqs, spectrum, time, original, /inverse
dft, freqs, spec1, time, sig1, /inverse
dft, freqs, spec2, time, sig2, /inverse
dft, freqs, spec3, time, sig3, /inverse
dft, freqs, spec4, time, sig4, /inverse

!p.multi = [0,2,5]

plot, time[0:400]*10.^6, original[0:400], title='Original Signal: Square Wave, 62.5 kHz, DFT -> IDFT', $
      xtitle='Time (microseconds)', ytitle='Amplitude (V)', background=!white, $
      color=!black, psym=-4, charsize=1.5
plot, freqs/10.^6, psorig, title='Original Power Spectrum', $
      xtitle='Frequency (MHz)', ytitle='Power', background=!white, $
      color=!black, psym=-4, charsize=1.5, yrange=[0,40]


plot, time[0:400]*10.^6, sig1[0:400], title='Slightly Filtered', $
      xtitle='Time (microseconds)', ytitle='Amplitude (V)', background=!white, $
      color=!black, psym=-4, charsize=1.5
plot, freqs/10.^6, ps1, title='Slightly Filtered Spectrum', $
      xtitle='Frequency (MHz)', ytitle='Power', background=!white, $
      color=!black, psym=-4, charsize=1.5, yrange=[0,40]


plot, time[0:400]*10.^6, sig2[0:400], title='Slightly More Filtered', $
      xtitle='Time (microseconds)', ytitle='Amplitude (V)', background=!white, $
      color=!black, psym=-4, charsize=1.5
plot, freqs/10.^6, ps2, title='Slightly More Filtered Spectrum', $
      xtitle='Frequency (MHz)', ytitle='Power', background=!white, $
      color=!black, psym=-4, charsize=1.5, yrange=[0,40]


plot, time[0:400]*10.^6, sig3[0:400], title='More Filtered', $
      xtitle='Time (microseconds)', ytitle='Amplitude (V)', background=!white, $
      color=!black, psym=-4, charsize=1.5
plot, freqs/10.^6, ps3, title='More Filtered Spectrum', $
      xtitle='Frequency (MHz)', ytitle='Power', background=!white, $
      color=!black, psym=-4, charsize=1.5, yrange=[0,40]


plot, time[0:400]*10.^6, sig4[0:400], title='Competely Filtered', $
      xtitle='Time (microseconds)', ytitle='Amplitude (V)', background=!white, $
      color=!black, psym=-4, charsize=1.5
plot, freqs/10.^6, ps4, title='Completely Filtered Spectrum', $
      xtitle='Frequency (MHz)', ytitle='Power', background=!white, $
      color=!black, psym=-4, charsize=1.5, yrange=[0,40]
end
