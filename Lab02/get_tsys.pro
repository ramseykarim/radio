;+
;NAME    GET_TSYS
;
;
;DESCRIPTION
;        Given cold sky and noise calibration data (we stood in
;        front of the horn), finds the system's inherent noise
;        level in preparation to remove noise from the signal.
;        Program takes SAMP sets of N samples, transforms them
;        spectra, and then divides the sum of the coldsky measurements
;        by the difference between the sum of the coldsky measurements
;        and the 300K measurements.
;
;        T_sys,coldsky = SUM(T_cold)/SUM(T_hot - T_cold)
;                      = SUM(T_cold)/(SUM(T_hot) - SUM(T_cold))
;
;
;CALLING SEQUENCE
;        get_tsys, N, SAMP
;
;
;INPUTS
;        N:
;        The desired length of the tsys array. A larger sample
;        size will give greater accuracy in the calculation but
;        will take longer to process. N should be a power of 2
;        in order for the FFT to work corrently, and has a hard
;        maximum of 16000 (8192 is the largest usable power of 2).
;
;        SAMP:
;        The desired number of data sets to average across. The
;        procedure calculates the average of these sets, but
;        the median can also be useful (this must be changed from
;        within the code). Most of the data was taken with 10000
;        sets, so 10000 is the hard maximum. 10000 will take a very
;        long time to process, especially with a large N; 1000
;        sets will work and won't take very long with a reasonable N.
;
;
;OUTPUT
;        The procedure saves the tsys array as the TSYS variable
;        in a .sav file named 'tsys' with the N and SAMP in the
;        filename.
;
;
;EXAMPLE
;IDL> get_tsys, 1024, 1000
;---------------------------------------------------------------------
;-

pro get_tsys, N, samp

  restore, 'coldsky.sav'
  print, 'Coldsky.sav restored'
  cold = data
  restore, 'standinfront.sav'
  print, 'Standinfront.sav restored'
  threehunna = data
  
  ps_c_tot = make_array(N, /integer, value=0)
  ps_h_tot = make_array(N, /integer, value=0)

  for i=0,samp-1 do begin
     ftc = FFT(complex(cold[0:N-1, 0, i], cold[0:N-1, 1, i]), /center)
     psc = ftc*conj(ftc)
     ps_c_tot = ps_c_tot + psc

     fth = FFT(complex(threehunna[0:N-1, 0, i], threehunna[0:N-1, 1, i]), /center)
     psh = fth*conj(fth)
     ps_h_tot = ps_h_tot + psh

     print, strtrim(string(100*float(i)/float(samp)), 1)+' % Complete'
  endfor

  help, ps_c_tot
  help, ps_h_tot

  ps_c_tot = ps_c_tot/float(samp)
  ps_h_tot = ps_h_tot/float(samp)

  help, ps_c_tot
  help, ps_h_tot

  tsys = 300.*total(ps_c_tot)/(total(ps_h_tot) - total(ps_c_tot))

  fsamp = 10.^6 * 62.5/8.

  strn = strtrim(string(N), 1)
  strsamp = strtrim(string(samp), 1)

  save, tsys, filename='tsysN'+strn+'SAMP'+strsamp+'.sav', $
        description='VARIABLE: tsys, N = '+strn+', SAMP = '+strsamp

end
