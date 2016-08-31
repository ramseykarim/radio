;+
;NAME    GET_SHAPE
;
;
;DESCRIPTION
;        Given online and offline data, finds the shape of the
;        measured spectrum in preparation to remove the inherent noise
;        from the signal.
;        Program averages spectra (MEAN method) for both online and
;        offline takes so that there remains one good online spectrum
;        and one good offline spectrum. Then, the online spectrum is
;        divided by the offline spectrum to remove the inherent shape
;        to both of them and highlight the differences between the two
;        spectra. Ideally, the only difference between the online
;        and offline spectra is the signal of interest. Additionally,
;        this division leaves the shape array centered around 1 so
;        that it can be easily and predictably rescaled.
;
;        |T_line| = online/offline
;
;        Additionally, this program was built for online and offline
;        .sav files that are just arrays, not data structures.
;        The arrays are expected to be of dimensions
;        [16000, 2, 10000], which is what the GETPICO procedure
;        naturally outputs for a dual sampling with nsp=10000.
;
;
;CALLING SEQUENCE
;        get_shape, N, SAMP
;
;
;INPUTS
;        N:
;        The desired length of the shape array. A larger sample
;        size will give greater accuracy in the shape but will
;        take longer to process. N should be a power of 2 in order
;        for the FFT to work correctly, and has a hard maximum of
;        16000 (8192 is the largest usable power of 2).
;
;        SAMP:
;        The desired number of data sets to average across. The
;        procedure uses the MEAN function to average data, but the
;        median can also be used (it must be changed from within;
;        the code). More sample sets will give greater accuracy but;
;        will take longer to process. Most of the data was taken with
;        10000 sets, so 10000 is the hard maximum. 10000 will take a
;        very long time to process, especially with a large N; 1000
;        sets will work and won't take very long with a reasonable N.
;
;
;OUTPUT
;        The procedure saves the shape array as the SHAPE variable in
;        a .sav file named 'shape' with the N and SAMP in the file
;        name.
;
;
;EXAMPLE
;IDL> get_shape, 1024, 1000
;
;---------------------------------------------------------------------
;-

pro getspectra_online, N, samp, div, var

  restore, 'pointedonline.sav'
  print, 'Data restored: ondata.sav'
  data = data[0:samp-1, 0:N-1]

  
  fsamp = (62.5/div)*10.^6
  ranges = (findgen(N) - N/2)
  frange = ranges*fsamp/N
  
  ps_sets= []

  for i=0,samp-1 do begin
     print, strtrim(string(100.*float(i)/float(samp)), 1)+' % Complete'
     ft = FFT(data[i, *], /center)
     ps_sets = [ps_sets, ft*conj(ft)]
  endfor
  
  
  ps_tot1 = mean(ps_sets, DIMENSION=1)
  var = transpose(ps_tot1)

end

pro getspectra_offline, N, samp, div, var, frange

  restore, 'pointedoffline.sav'
  print, 'Data Restored: offdata.sav'
  data = offdata[0:samp-1, 0:N-1]

  
  fsamp = (62.5/div)*10.^6
  ranges = (findgen(N) - N/2)
  frange = ranges*fsamp/N
  
  ps_sets= []

  for i=0,samp-1 do begin
     print, strtrim(string(100*float(i)/float(samp)), 1)+' % Complete'
     ft = FFT(data[i, *], /center)
     ps_sets = [ps_sets, ft*conj(ft)]
  endfor

  ps_tot1 = mean(ps_sets, DIMENSION=1)
  var = transpose(ps_tot1)

end


pro get_shape, N, samp
;  psopen, 'Shape.ps', xsize=10, ysize=8, /inches, /color
  div = 8
  online_dat = !null
  offline_dat = !null
  frange = !null
  getspectra_online, N, samp, div, online_dat
  getspectra_offline, N, samp, div, offline_dat, frange

  strn = strtrim(string(N), 1)
  strsamp = strtrim(string(samp), 1)

  shape = online_dat / offline_dat
  shape = transpose(shape)

  plot, frange/(10.^6), shape, title='Shape of measured spectrum', $
        xtitle='Freq (MHz)', charsize=2, psym=-4, $
        ytitle='Ratio: Online/Offline', background=!white, $
        color=!black

  save, shape, filename='shapeN'+strn+'SAMP'+strsamp+'.sav', $
        description='VARIABLE: shape, N = '+strn+', SAMP = '+strsamp

; psclose
end
